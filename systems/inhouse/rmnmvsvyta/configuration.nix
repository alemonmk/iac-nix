{
  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.8/26"
      "2400:8902:e002:59e3::a34:910e/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  fileSystems."/mnt/pfs3/ytarchive" = {
    device = "rmnmpfss03.snct.rmntn.net:/volume1/YoutubeArchive";
    fsType = "nfs";
    options = ["nfsvers=4.1"];
  };

  services.caddy.enable = true;

  imports = [
    ./jellyfin.nix
    ./metube.nix
  ];
}
