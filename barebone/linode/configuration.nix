{ pkgs, ... }:
{
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

  system.stateVersion = "25.05";
  nixpkgs.hostPlatform = "x86_64-linux";
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-community.cachix.org"
      "https://nix-cache.snct.rmntn.net"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-cache.snct.rmntn.net-1:PmTrNIvPsGTWCJlXEf1g29ixPemUp68gkgqNA/YcfsM="
    ];
  };

  networking = {
    hostName = "nixos-installed";
    domain = "rmntn.net";
    timeServers = [ "ats1.e-timing.ne.jp" ];
    useDHCP = true;
    usePredictableInterfaceNames = false;
  };

  environment.systemPackages = [ pkgs.git ];

  services = {
    lvm.enable = false;
    openssh = {
      enable = true;
      ports = [ 444 ];
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
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICPf29QH5R+ydLAllJNX7FM5SAguXnbJXmImmShFksMk"
  ];
  users.users.emergency = {
    isNormalUser = true;
    description = "Emergency local account";
    extraGroups = [ "wheel" ];
    home = "/home/emergency";
    createHome = true;
    hashedPassword = "$y$j9T$xFls5U8.oYFxKFI8JUMgW0$FgKAm0BA/xc/JZaXrAJQwhYUK.TMboBo/S0iPaOb0BB";
  };
}
