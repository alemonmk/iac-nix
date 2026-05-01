{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.81.70.19/28"
      "2400:8902:e002:59e2::53b1/64"
    ];
    gateway = [
      "10.81.70.30"
      "2400:8902:e002:59e2::ccef"
    ];
    networkConfig.LLDP = false;
  };
}
