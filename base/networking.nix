{config, ...}: {
  networking = {
    domain = "snct.rmntn.net";
    useDHCP = false;
    timeServers = ["rmnmvntpsrv01.snct.rmntn.net"];
    nameservers = ["10.85.11.1" "10.85.11.2"];
    firewall.enable = false;
  };
  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
