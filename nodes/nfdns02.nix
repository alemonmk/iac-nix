{
  networking.hostName = "rmnmvnfdns02";

  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.10.2/27"
      "2400:8902:e002:59e0::d:2/64"
    ];
    gateway = [
      "10.85.10.30"
      "2400:8902:e002:59e0::ccef"
    ];
    networkConfig.LLDP = false;
  };

  services = {
    technitium-dns-server = {
      enable = true;
    };
    caddy = {
      enable = true;
      virtualHosts = {
        "dns02.noc.snct.rmntn.net" = {
          extraConfig = ''
            reverse_proxy localhost:5380 {
                  header_up X-Real-IP {remote_host}
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/private/technitium-dns-server"];
}
