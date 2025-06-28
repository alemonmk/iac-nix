{
  networking.proxy = {
    httpProxy = null;
    httpsProxy = null;
  };

  systemd.network = {
    config.networkConfig = {
      IPv4Forwarding = true;
      IPv6Forwarding = true;
    };
    networks."1-ens192" = {
      matchConfig.Name = "ens192";
      address = [
        "10.85.29.3/28"
        "2400:8902:e002:59e9::8e01/64"
      ];
      gateway = [
        "10.85.29.1"
        "2400:8902:e002:59e9::1"
      ];
      networkConfig.LLDP = false;
    };
  };

  users.ms-ad.enable = false;

  imports = [ ./remote-access-vpn.nix ];
}
