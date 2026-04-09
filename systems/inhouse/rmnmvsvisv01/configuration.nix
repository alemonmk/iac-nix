{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.101.9/29"
      "2400:8902:e002:59ee::4c84:57a1/64"
    ];
    gateway = [
      "10.85.101.14"
      "2400:8902:e002:59ee::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [
    ./vault.nix
  ];
}
