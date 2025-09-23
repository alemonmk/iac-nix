{ pkgs, ... }:
{
  nix.channel.enable = false;
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    min-free = 512 * 1024 * 1024;
    log-lines = 25;
    tarball-ttl = 60;
    substituters = [
      "https://nix-community.cachix.org"
      "https://nix-cache.snct.rmntn.net"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-cache.snct.rmntn.net-1:PmTrNIvPsGTWCJlXEf1g29ixPemUp68gkgqNA/YcfsM="
    ];
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../overlays/stable.nix) ];
  };
  environment.systemPackages = [
    pkgs.git
    pkgs.nvd
  ];
  environment.shellAliases = {
    upgrade-system = "sudo nixos-rebuild switch --flake git+https://code.rmntn.net/iac/nix#$(hostname); upgrade-diff";
    upgrade-system-reboot = "sudo nixos-rebuild boot --flake git+https://code.rmntn.net/iac/nix#$(hostname); upgrade-diff; read -n 1 -s -p 'Press any key when ready to reboot'; sudo reboot";
    upgrade-diff = "nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)";
  };
}
