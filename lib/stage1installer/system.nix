{
  lib,
  pkgs,
  ...
}:
{
  system.stateVersion = "24.11";
  boot.kernelParams = [
    "quiet"
    "systemd.show_status=no"
  ];
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "vmw_pvscsi"
    "sd_mod"
    "vmxnet3"
    "vmw_vmci"
    "vmwgfx"
    "vmw_vsock_vmci_transport"
  ];
  boot.supportedFilesystems = [
    "ext4"
    "btrfs"
  ];
  virtualisation.vmware.guest.enable = true;
  networking.hostName = "nixos-installer";
  networking.useDHCP = true;
  networking.networkmanager.enable = lib.modules.mkForce false;
  networking.firewall.enable = false;
  fonts.fontconfig.enable = false;
  hardware.enableAllFirmware = false;
  environment.systemPackages = with pkgs; [
    gitMinimal
    btrfs-progs
  ];
  nix.settings = {
    extra-experimental-features = [
      "nix-command"
      "flakes"
    ];
    accept-flake-config = true;
  };
}
