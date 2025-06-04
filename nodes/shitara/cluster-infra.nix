{
  config,
  lib,
  ...
}: let
  netConfig = (import ./netconfigs.nix).getNetConfig config.networking.hostName;
  loAddress = netConfig.lo;
  wanAddress = netConfig.wan;
in {
  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname "eth0" tcp dport https counter accept
      iifname "eth0" tcp dport 53 counter accept
      iifname "eth0" udp dport 53 counter accept
      iifname "ztinv*" ip saddr {10.85.183.0/28, 10.91.145.32/28} ip daddr 10.85.183.0/28 counter accept
      iifname ne "eth0" ip saddr {10.85.10.1, 10.85.10.2} ip daddr 10.85.183.0/28 udp dport 8600 counter accept # Consul DNS
      iifname ne "eth0" ip saddr {10.85.10.5, 10.80.100.0/23, 10.80.105.0/24} ip daddr 10.85.183.0/28 tcp dport 4646 counter accept # Nomad API
      iifname ne "eth0" ip saddr {10.85.10.5, 10.80.100.0/23, 10.80.105.0/24} ip daddr 10.85.183.0/28 tcp dport 8500 counter accept # Consul API
      iifname ne "eth0" ip saddr 10.85.20.66 ip daddr 10.85.183.0/28 tcp dport 5432 counter accept # Postgres cross site replication
    }
  '';

  services = {
    consul = {
      enable = true;
      webUi = true;
      extraConfig = {
        datacenter = "shitara";
        client_addr = loAddress;
        bind_addr = loAddress;
        server = true;
        bootstrap_expect = 3;
        retry_join =
          builtins.map
          (x: "10.85.183.${builtins.toString x}:8301")
          (lib.lists.range 1 5);
        node_meta.wan_address_v4 = wanAddress.v4;
        node_meta.wan_address_v6 = wanAddress.v6;
        discard_check_output = true;
        telemetry = {
          prometheus_retention_time = "60s";
          disable_hostname = true;
        };
        disable_update_check = true;
      };
    };

    nomad = {
      enable = true;
      enableDocker = true;
      dropPrivileges = false;
      settings = {
        region = "jp";
        datacenter = "shitara";
        bind_addr = loAddress;
        consul.address = "${loAddress}:8500";
        server = {
          enabled = true;
          bootstrap_expect = 3;
          rejoin_after_leave = true;
          default_scheduler_config = {
            scheduler_algorithm = "spread";
            memory_oversubscription_enabled = true;
          };
        };
        client = {
          enabled = true;
          alloc_dir = "/opt/nomad/alloc";
          alloc_mounts_dir = "/opt/nomad/alloc-mounts";
          host_network = [
            {public = [{interface = "eth0";}];}
            {private = [{cidr = "10.85.183.0/28";}];}
          ];
          host_volume = [
            {"postgres-db" = [{path = "/opt/database/postgres";}];}
          ];
        };
        plugin = [
          {
            docker = {
              config = {
                allow_privileged = true;
                volumes.enabled = true;
              };
            };
          }
        ];
        telemetry = {
          prometheus_metrics = true;
          use_node_name = true;
        };
        ui = {
          enabled = true;
          consul.ui_url = "http://consul.service.consul:8500/ui";
        };
        disable_update_check = true;
      };
    };
  };
}
