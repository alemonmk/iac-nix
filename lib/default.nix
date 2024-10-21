{
  system ? "x86_64-linux",
  self,
  nixpkgs,
  nixpkgs-unstable,
  impermanence,
  sops-nix,
  disko,
  unattended-installer,
  ...
} @ inputs:
let
  skeleton = nixpkgs.lib.nixosSystem {
    modules = [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ({...}:{
        nixpkgs.hostPlatform = "x86_64-linux";
        system.stateVersion = "24.05";})
    ];
  };
in {
  stage1Installer = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; installTarget = skeleton; };
    modules = [
      unattended-installer.nixosModules.diskoInstaller
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
        system.stateVersion = "24.05";
        boot.kernelPackages = pkgs.linuxPackages_6_6;
        boot.kernelParams = ["quiet" "systemd.show_status=no"];
        boot.initrd.availableKernelModules = lib.mkForce ["ata_piix" "vmw_pvscsi" "sd_mod" "vmxnet3" "vmw_vmci" "vmwgfx" "vmw_vsock_vmci_transport"];
        virtualisation.vmware.guest.enable = true;
        networking.hostName = "nixos-installer";
        networking.useDHCP = true;
        networking.networkmanager.enable = false;
        fonts.fontconfig.enable = false;
        hardware.enableAllFirmware = false;
        unattendedInstaller = {
          enable = true;
          target = installTarget;
          flake = "git+https://code.rmntn.net/iac/nix#barebone";
          showProgress = true;
          waitForNetwork = true;
          postDisko = ''
            btrfs subvolume snapshot -r /mnt/rootfs /mnt/rootfs-0
            echo "Created empty rootfs snapshot."
          '';
          preInstall = ''
            mkdir -p /mnt/nix/persist/{etc/{nixos,ssh},var/{lib/nixos,lib/sss,log}}
            mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
            mount -o bind /mnt/nix/persist/var/log /mnt/var/log
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
}
