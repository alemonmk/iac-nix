{
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

  imports = [ ./dns-server.nix ];
}
