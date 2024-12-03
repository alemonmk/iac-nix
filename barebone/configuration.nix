{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  system.stateVersion = "24.11";
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["ata_piix" "vmw_pvscsi" "sd_mod"];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  fileSystems."/nix".neededForBoot = true;
  boot.initrd.supportedFilesystems = ["btrfs"];
  boot.initrd.postResumeCommands = ''
    mkdir -p /mnt/btrfs_root
    mount -o subvol=/ /dev/disk/by-partlabel/ROOT /mnt/btrfs_root

    echo "Deleteing sub-subvolumes..."
    btrfs subvolume list -o /mnt/btrfs_root/rootfs |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/btrfs_root/$subvolume"
    done &&

    echo "Deleting rootfs subvolume..."
    btrfs subvolume delete /mnt/btrfs_root/rootfs

    echo "Restoring blank rootfs subvolume..."
    btrfs subvolume snapshot /mnt/btrfs_root/rootfs-0 /mnt/btrfs_root/rootfs

    umount /mnt/btrfs_root
  '';

  virtualisation.vmware.guest.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos-installed";
  networking.useDHCP = true;

  environment.systemPackages = [pkgs.git pkgs.dnsutils];

  services = {
    openssh = {
      enable = true;
      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
      settings.KbdInteractiveAuthentication = false;
      extraConfig = ''
        AllowTcpForwarding no
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
      '';
    };
  };

  users.mutableUsers = false;
  users.users.emergency = {
    isNormalUser = true;
    description = "Emergency local account";
    extraGroups = ["wheel"];
    home = "/home/emergency";
    createHome = true;
    hashedPassword = "$y$j9T$xFls5U8.oYFxKFI8JUMgW0$FgKAm0BA/xc/JZaXrAJQwhYUK.TMboBo/S0iPaOb0BB";
  };
}
