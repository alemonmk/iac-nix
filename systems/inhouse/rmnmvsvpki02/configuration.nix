{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.101.2/29"
      "2400:8902:e002:59ef::5701:ce01/64"
    ];
    gateway = [
      "10.85.101.6"
      "2400:8902:e002:59ef::ccef"
    ];
    networkConfig.LLDP = false;
  };

  imports = [
    ./secrets.nix
    ./step-ca.nix
  ];
}
