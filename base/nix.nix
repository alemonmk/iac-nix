{config, ...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    min-free = 512 * 1024 * 1024;
    log-lines = 25;
  };
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };
}
