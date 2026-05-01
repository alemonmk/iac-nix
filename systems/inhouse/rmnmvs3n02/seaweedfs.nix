{ config, ... }:
{
  fileSystems."/s3" = {
    device = "/dev/disk/by-partlabel/S3";
    fsType = "ext4";
    options = [ "noatime" ];
    autoResize = true;
  };

  services.caddy.enable = true;

  services.seaweedfs = {
    listenAddr = "10.81.70.20";
    dataCenter = "MO-PDC";
    rack = "R2";
    volume.allVolumesSizeMB = 307200;
  };
}
