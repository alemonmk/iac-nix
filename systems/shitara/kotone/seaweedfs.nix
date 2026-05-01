{ self, ... }:
{
  imports = [
    self.nixosModules.seaweedfs
    self.nixosModules.seaweedfs-cluster
    self.nixosModules.caddy-defaults
  ];

  services.seaweedfs = {
    listenAddr = "10.85.183.6";
    dataCenter = "shitara";
    rack = "kotone";
    volume.allVolumesSizeMB = 51200;
  };

  services.caddy = {
    virtualHosts."objects.snct.rmntn.net" = {
      listenAddresses = [ "10.85.183.6" ];
    };
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname ne "eth0" ip saddr {10.81.70.19, 10.81.70.20} ip daddr 10.85.183.6 tcp dport {5300-5303, 5310-5313} counter accept
    }
  '';
}
