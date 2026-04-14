{
  config,
  lib,
  ...
}:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.lists) optionals;
  inherit (lib.strings) optionalString;
  netConfig = import ./netconfigs.nix config.networking.hostName;
  loAddress = netConfig.lo;
  wanAddress = netConfig.wan;
in
{
  systemd.tmpfiles.settings = mkIf config.services.nomad.enable {
    "15-nomad-dirs" = {
      "/opt/nomad/alloc".d = {
        mode = "0711";
        user = "root";
        group = "root";
      };
      "/opt/nomad/alloc-mounts".d = {
        mode = "0711";
        user = "root";
        group = "root";
      };
    };
    "15-postgres"."/opt/database/postgres".d = {
      mode = "0700";
      user = "999";
      group = "999";
    };
  };

  services = {
    consul = {
      enable = mkDefault true;
      webUi = true;
      extraConfig = {
        datacenter = "shitara";
        client_addr = loAddress;
        bind_addr = loAddress;
        server = true;
        bootstrap_expect = 3;
        retry_join = [
          "10.85.183.1:8301"
          "10.85.183.2:8301"
          "10.85.183.3:8301"
          "10.85.183.4:8301"
          "10.85.183.5:8301"
        ];
        node_meta = {
          wan_address_v4 = wanAddress.v4;
          wan_address_v6 = wanAddress.v6;
        };
        discard_check_output = true;
        telemetry = {
          prometheus_retention_time = "60s";
          disable_hostname = true;
        };
        disable_update_check = true;
      };
    };

    nomad = {
      enable = mkDefault true;
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
          options."fingerprint.network.disallow_link_local" = true;
          host_network = [
            { public_v4 = [ { cidr = "${wanAddress.v4}/32"; } ]; }
            { public_v6 = [ { cidr = "${wanAddress.v6}/128"; } ]; }
            { private = [ { cidr = "10.85.183.0/28"; } ]; }
          ];
          host_volume = [
            { "postgres-db" = [ { path = "/opt/database/postgres"; } ]; }
          ];
        };
        plugin = [
          {
            docker.config = {
              allow_privileged = true;
              volumes.enabled = true;
            };
          }
        ];
        telemetry = {
          prometheus_metrics = true;
          publish_allocation_metrics = true;
          use_node_name = true;
        };
        ui = {
          enabled = true;
          consul.ui_url = "http://consul.service.consul:8500/ui";
        };
        disable_update_check = true;
      };
    };

    resolved = {
      enable = true;
      llmnr = "false";
      fallbackDns = [
        "127.0.0.1"
        "::1"
      ];
    };

    unbound = {
      enable = true;
      settings = {
        server =
          let
            private-domains = [
              "consul"
              "snct.rmntn.net"
              "10.in-addr.arpa"
            ];
          in
          {
            do-not-query-localhost = true;
            unblock-lan-zones = true;
            insecure-lan-zones = true;
            private-domain = private-domains;
            domain-insecure = private-domains;
          };
        forward-zone = [
          {
            name = "consul";
            forward-addr = [
              "10.85.183.1@8600"
              "10.85.183.2@8600"
              "10.85.183.3@8600"
              "10.85.183.4@8600"
              "10.85.183.5@8600"
            ];
          }
        ];
        stub-zone =
          let
            ad-dns-servers = [
              "10.85.11.1"
              "10.85.11.2"
            ];
          in
          [
            {
              name = "snct.rmntn.net";
              stub-addr = ad-dns-servers;
            }
            {
              name = "10.in-addr.arpa";
              stub-addr = ad-dns-servers;
            }
          ];
      };
    };
  };

  systemd.services = {
    nomad.after = optionals (config.services.consul.enable) [ "consul.service" ];
    consul.after = optionals (config.services.consul.enable) [
      "bird.service"
      "unbound.service"
    ];
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname "ztinv*" ip saddr {10.85.183.0/28, 10.91.145.32/28} ip daddr 10.85.183.0/28 counter accept
    }
  ''
  + optionalString (config.services.consul.enable) ''
    chain service-input {
      iifname ne "eth0" ip saddr {10.85.10.1, 10.85.10.2} ip daddr 10.85.183.0/28 udp dport 8600 counter accept # Consul DNS
      iifname ne "eth0" ip saddr {10.85.10.5, 10.80.100.0/23, 10.80.105.0/24} ip daddr 10.85.183.0/28 tcp dport 8500 counter accept # Consul API
    }
  ''
  + optionalString (config.services.nomad.enable) ''
    chain service-input {
      iifname "eth0" tcp dport https counter accept
      iifname "eth0" tcp dport 53 counter accept
      iifname "eth0" udp dport 53 counter accept
      iifname ne "eth0" ip saddr {10.85.10.5, 10.80.100.0/23, 10.80.105.0/24} ip daddr 10.85.183.0/28 tcp dport 4646 counter accept # Nomad API
      iifname ne "eth0" ip saddr 10.85.20.12 ip daddr 10.85.183.0/28 tcp dport 5432 counter accept # Postgres backup appliance
    }
  '';
}
