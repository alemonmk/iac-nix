{
  system ? "x86_64-linux",
  self,
  nixpkgs,
  nixpkgs-next,
  impermanence,
  sops-nix,
  disko,
  home-manager-linux,
  ...
} @ inputs: {
  stage1Installer = let
    dummyTarget = nixpkgs.lib.nixosSystem {
      modules = [
        disko.nixosModules.disko
        ../barebone/diskolayout.nix
        ({...}: {
          nixpkgs.hostPlatform = "x86_64-linux";
          system.stateVersion = "24.11";
        })
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
      mkdir -p /mnt/nix/persist/{etc/{nixos,ssh},var/{lib/nixos,lib/sss,log}}
      mount -o bind -m /mnt/nix/persist/etc/nixos /mnt/etc/nixos
      mount -o bind -m /mnt/nix/persist/var/log /mnt/var/log
    '';
    image = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs;};
      modules = [
        self.stage1InstallerModules
        ({
          modulesPath,
          lib,
          pkgs,
          ...
        }: {
          imports = [
            "${modulesPath}/installer/netboot/netboot-minimal.nix"
            "${modulesPath}/profiles/perlless.nix"
            ./stage1installer/system.nix
            ./stage1installer/minimalize.nix
          ];
          disabledModules = ["profiles/base.nix"];
          unattendedInstaller = {
            enable = true;
            target = dummyTarget;
            flake = "git+https://code.rmntn.net/iac/nix?ref=main#barebone";
            preInstall = preInstallMounts;
          };
        })
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
          overlays = [(import ../overlays/stable.nix)];
          config.allowUnfree = true;
        };
        nixpkgs-next = import nixpkgs-next {
          inherit system;
          overlays = [(import ../overlays/next.nix)];
          config.allowUnfree = true;
          config.permittedInsecurePackages = ["squid-7.0.1"];
        };
      };
      modules =
        [
          self.nixosModules
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager-linux.nixosModules.home-manager
        ]
        ++ sysDef;
    };
}
