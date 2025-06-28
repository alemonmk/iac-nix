{ lib, ... }:
{
  networking = {
    domain = "snct.rmntn.net";
    search = [
      "snct.rmntn.net"
      "clients.snct.rmntn.net"
    ];
    useNetworkd = true;
    useDHCP = false;
    timeServers = [ "rmnmvntpsrv01.snct.rmntn.net" ];
    nameservers = [
      "10.85.10.1"
      "10.85.10.2"
      "2400:8902:e002:59e0::d:1"
      "2400:8902:e002:59e0::d:2"
    ];
    firewall.enable = false;
    proxy = lib.mkDefault {
      httpProxy = "http://10.85.20.10:3128";
      httpsProxy = "http://10.85.20.10:3128";
      noProxy = "127.0.0.1,localhost,.snct.rmntn.net";
    };
  };
  services.resolved.llmnr = "false";

  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 134217728;
    "net.core.rmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.core.netdev_max_backlog" = 30000;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.core.default_qdisc" = "fq";
  };
}
