{config, ...}: {
  networking = {
    domain = "snct.rmntn.net";
    useDHCP = false;
    timeServers = ["rmnmvntpsrv01.snct.rmntn.net"];
    nameservers = ["10.85.10.1" "10.85.10.2" "2400:8902:e002:59e0::d:1" "2400:8902:e002:59e0::d:2"];
    firewall.enable = false;
  };
}
