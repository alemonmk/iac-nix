{
  nixpkgs,
  disko,
  ...
}: let
  linuxSystem = "x86_64-linux";
  dummyTarget = nixpkgs.lib.nixosSystem {
    system = linuxSystem;
    modules = [
      disko.nixosModules.disko
      ../../barebone/diskolayout.nix
    ];
  };
  preInstallMounts = ''
    umount -Rv /mnt
    mount -o subvol=/ /dev/disk/by-partlabel/ROOT /mnt
    btrfs subvolume snapshot -r /mnt/rootfs /mnt/rootfs-0
    umount -v /mnt
    mount -o noatime,subvol=/rootfs /dev/disk/by-partlabel/ROOT /mnt
    mount -o umask=0077 -t vfat /dev/disk/by-partlabel/EFI /mnt/boot
    mount -t ext4 /dev/disk/by-partlabel/NIX /mnt/nix
    mkdir -p /mnt/nix/persist/{etc/ssh,var/{lib/nixos,log}}
    mount -o bind -m /mnt/nix/persist/var/log /mnt/var/log
  '';
  image = nixpkgs.lib.nixosSystem {
    system = linuxSystem;
    modules = [
      "${nixpkgs}/nixos/modules/installer/netboot/netboot-minimal.nix"
      "${nixpkgs}/nixos/modules/profiles/perlless.nix"
      ../../modules/installer
      ./system.nix
      ./minimalize.nix
      {
        disabledModules = ["profiles/base.nix"];
        unattendedInstaller = {
          enable = true;
          target = dummyTarget;
          flake = "git+https://code.rmntn.net/iac/nix?ref=main#barebone";
          preInstall = preInstallMounts;
        };
      }
    ];
  };
in
  with image;
    pkgs.symlinkJoin {
      name = "netbootImage";
      paths = with config.system.build; [
        netbootRamdisk
        kernel
        netbootIpxeScript
      ];
      preferLocalBuild = true;
    }
