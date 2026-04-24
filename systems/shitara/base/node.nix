{ config, ... }:
{
  imports = [
    ./firewall.nix
    ./cluster-overlay.nix
    ./mopdc-tunnel.nix
    ./cluster-infra.nix
  ];

  time.timeZone = "Asia/Tokyo";

  systemd.network = {
    networks."2-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        LLDP = false;
        IPv6AcceptRA = true;
      };
      dhcpV4Config.UseDNS = false;
    };
  };

  virtualisation.docker.daemon.settings = {
    iptables = false;
    ip6tables = false;
  };

  services.prometheus.exporters.node =
    let
      netConfig = import ./netconfigs.nix config.networking.hostName;
    in
    {
      enable = true;
      listenAddress = netConfig.lo;
      extraFlags = [ "--collector.disable-defaults" ];
      enabledCollectors = [
        "cpu"
        "meminfo"
        "loadavg"
        "netdev"
        "stat"
      ];
    };

  networking.nftables.tables.global.content =
    let
      promNodeExporterPort = toString config.services.prometheus.exporters.node.port;
    in
    ''
      chain service-input {
        ip saddr 10.85.10.5 tcp dport ${promNodeExporterPort} counter accept
      }
    '';
}
