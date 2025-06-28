{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.66/26"
      "2400:8902:e002:59e4::39b:84e0/64"
    ];
    gateway = [
      "10.85.20.126"
      "2400:8902:e002:59e4::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [
    ./secrets.nix
    ./pgsql.nix
  ];
}
