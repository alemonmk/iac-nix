{config, ...}: {
  imports = [
    ./firewall.nix
    ./cluster-overlay.nix
    ./mopdc-tunnel.nix
    ./cluster-infra.nix
    ./unbound.nix
  ];

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    age.generateKey = true;
    secrets.ipsec_psk.sopsFile = ../../secrets/shitara/ipsec.yaml;
  };

  time.timeZone = "Asia/Tokyo";

  systemd.network = {
    enable = true;
    networks."2-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        LLMNR = false;
        MulticastDNS = false;
        IPv6AcceptRA = true;
      };
      dhcpV4Config.UseDNS = false;
      extraConfig = ''
        [Address]
        ManageTempAddress = false
      '';
    };
  };

  virtualisation.docker.daemon.settings = {
    iptables = false;
    ip6tables = false;
  };

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = ((import ./netconfigs.nix).getNetConfig config.networking.hostName).lo;
    extraFlags = ["--collector.disable-defaults"];
    enabledCollectors = [
      "cpu"
      "meminfo"
      "loadavg"
      "netdev"
      "stat"
    ];
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      ip saddr 10.85.10.5 tcp dport ${toString config.services.prometheus.exporters.node.port} counter accept
    }
  '';
}
