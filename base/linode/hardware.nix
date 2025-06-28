{ config, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  boot.loader.timeout = 10;
  boot.loader.grub.enable = true;
  boot.loader.grub.forceInstall = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.kernelModules = [ "virtio_net" ];

  boot.initrd.availableKernelModules = [
    "virtio_net"
    "virtio_pci"
    "virtio_mmio"
    "virtio_blk"
    "virtio_scsi"
    "9p"
    "9pnet_virtio"
    "ahci"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "virtio_balloon"
    "virtio_console"
    "virtio_rng"
    "virtio_gpu"
  ];

  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/dev/sdb"; } ];
}
