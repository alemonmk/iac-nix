{pkgs, ...}: {
  nix.channel.enable = false;
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    min-free = 512 * 1024 * 1024;
    log-lines = 25;
    tarball-ttl = 60;
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [(import ../overlays/stable.nix)];
  };
  environment.systemPackages = [pkgs.git pkgs.nvd];
  environment.shellAliases = {
    upgrade-system = "sudo nixos-rebuild boot --flake git+https://code.rmntn.net/iac/nix#$(hostname); upgrade-diff";
    upgrade-diff = "nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)";
  };
}
