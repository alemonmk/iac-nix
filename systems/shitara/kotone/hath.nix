{
  lib,
  ...
}:
{
  fileSystems."/opt/hath" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_hath";
    fsType = "ext4";
  };

  systemd.tmpfiles.settings = {
    "10-hath" = {
      "/opt/hath".a.argument = "d:u:emergency:rx,u:emergency:rx";
      "/opt/hath/download".a.argument = "d:u:emergency:rwx,u:emergency:rwx";
    };
  };

  users.users.hath = {
    uid = 9999;
    group = "hath";
    isNormalUser = true;
    home = "/opt/hath";
  };
  users.groups.hath = {
    gid = 9999;
  };

  virtualisation.oci-containers.containers."hath" = {
    image = "frosty5689/hath:1.6.4";
    user = "9999:9999";
    networks = [ "host" ];
    capabilities.all = false;
    volumes = lib.lists.map (d: "/opt/hath/${d}:/hath/${d}") [
      "cache"
      "data"
      "download"
      "log"
      "tmp"
    ];
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname "eth0" tcp dport 8472 counter accept
    }
  '';
}
