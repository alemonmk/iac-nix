{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.7/26"
      "2400:8902:e002:59e3::9:1a/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [ ./chrony.nix ];
}
