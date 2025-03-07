{config, ...}: {
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
  environment.shellAliases = {
    upgrade-diff = "nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)";
  };
}
