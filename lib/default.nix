{
  system ? "x86_64-linux",
  self,
  nixpkgs,
  nixpkgs-next,
  impermanence,
  sops-nix,
  disko,
  # unattended-installer,
  ...
} @ inputs: let
  skeleton = nixpkgs.lib.nixosSystem {
    modules = [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ({...}: {
        nixpkgs.hostPlatform = "x86_64-linux";
        system.stateVersion = "24.05";
      })
    ];
  };
in {
  stage1Installer = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = {
      inherit inputs;
      installTarget = skeleton;
    };
    modules = [
      self.stage1InstallerModules
      ({
        modulesPath,
        lib,
        pkgs,
        installTarget,
        ...
      }: {
        imports = [
          "${modulesPath}/installer/netboot/netboot-minimal.nix"
        ];
        system.stateVersion = "24.11";
        boot.kernelPackages = pkgs.linuxPackages_6_6;
        boot.kernelParams = ["quiet" "systemd.show_status=no"];
        boot.initrd.availableKernelModules = ["ata_piix" "vmw_pvscsi" "sd_mod" "vmxnet3" "vmw_vmci" "vmwgfx" "vmw_vsock_vmci_transport"];
        virtualisation.vmware.guest.enable = true;
        networking.hostName = "nixos-installer";
        networking.useDHCP = true;
        networking.networkmanager.enable = false;
        fonts.fontconfig.enable = false;
        hardware.enableAllFirmware = false;
        environment.systemPackages = [pkgs.git pkgs.btrfs-progs];
        unattendedInstaller = {
          enable = true;
          target = installTarget;
          flake = "git+https://code.rmntn.net/iac/nix?ref=main#barebone";
          postDisko = ''
            umount -Rv /mnt
            mount -o subvol=/ /dev/disk/by-partlabel/ROOT /mnt
            btrfs subvolume snapshot -r /mnt/rootfs /mnt/rootfs-0
            umount -v /mnt
            mount -o noatime,subvol=/rootfs /dev/disk/by-partlabel/ROOT /mnt
            mount -o umask=0077 -t vfat /dev/disk/by-partlabel/EFI /mnt/boot
            mount -t ext4 /dev/disk/by-partlabel/NIX /mnt/nix
          '';
          preInstall = ''
            mkdir -p /mnt/nix/persist/{etc/{nixos,ssh},var/{lib/nixos,lib/sss,log}}
            mount -o bind -m /mnt/nix/persist/etc/nixos /mnt/etc/nixos
            mount -o bind -m /mnt/nix/persist/var/log /mnt/var/log
          '';
        };
        nix.settings = {
          extra-experimental-features = ["nix-command" "flakes"];
          accept-flake-config = true;
        };
      })
    ];
  };
  stage1System = nixpkgs.lib.nixosSystem {
    modules = [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ../barebone/configuration.nix
    ];
  };
  finalSystem = sysDef:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit impermanence sops-nix;
        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import ../overlays)];
          config.allowUnfree = true;
        };
        nixpkgs-next = import nixpkgs-next {
          inherit system;
          config.allowUnfree = true;
        };
      };
      modules =
        [
          self.nixosModules
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
        ]
        ++ sysDef;
    };
}
