{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.101.17/28"
      "2400:8902:e002:59ee::5701:ce01/64"
    ];
    gateway = [
      "10.85.101.30"
      "2400:8902:e002:59ee::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [
    ./secrets.nix
    ./step-ca.nix
  ];
}
