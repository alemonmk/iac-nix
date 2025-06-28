{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "vmw_pvscsi"
    "sd_mod"
  ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/EFI";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/ROOT";
    fsType = "btrfs";
    options = [
      "subvol=/rootfs"
      "noatime"
    ];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/NIX";
    fsType = "ext4";
    options = [ "noatime" ];
  };

  swapDevices = [ { device = "/dev/disk/by-partlabel/SWAP"; } ];

  virtualisation.vmware.guest.enable = true;
}
