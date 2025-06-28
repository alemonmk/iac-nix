{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.10/26"
      "2400:8902:e002:59e3::403:9ae7/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [ ./squid.nix ];
}
