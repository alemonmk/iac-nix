{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  system.stateVersion = "24.05";
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.supportedFilesystems = ["btrfs"];
  boot.initrd.availableKernelModules = ["ata_piix" "vmw_pvscsi" "sd_mod"];
  boot.kernelPackages = pkgs.linuxPackages_zen;

  virtualisation.vmware.guest.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nixos-installed";
  networking.useDHCP = true;

  environment.systemPackages = [pkgs.dnsutils];

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
}
