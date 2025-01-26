{config, lib, ...}: {
  networking = {
    domain = "snct.rmntn.net";
    useDHCP = false;
    timeServers = ["rmnmvntpsrv01.snct.rmntn.net"];
    nameservers = ["10.85.10.1" "10.85.10.2" "2400:8902:e002:59e0::d:1" "2400:8902:e002:59e0::d:2"];
    firewall.enable = false;
    proxy = lib.mkDefault {
      httpProxy = "http://10.85.20.10:3128";
      httpsProxy = "http://10.85.20.10:3128";
      noProxy = "127.0.0.1,localhost,.snct.rmntn.net";
    };
  };
}
