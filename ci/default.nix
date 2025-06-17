{inputs}: let
  inherit (inputs) self nixpkgs nixpkgs-next;
  pkgs-stable = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.permittedInsecurePackages = ["squid-7.0.1"];
  };
  pkgs-next = nixpkgs-next.legacyPackages.x86_64-linux;
  stable-overlay-realised = (import ../overlays/stable.nix) pkgs-stable pkgs-stable;
  next-overlay-realised = (import ../overlays/next.nix) pkgs-next pkgs-next;
  overlays-combined = stable-overlay-realised // next-overlay-realised;
in {
  hosts.x86_64-linux = nixpkgs.lib.mapAttrs (_: cfg: cfg.config.system.build.toplevel) self.nixosConfigurations;
  pkgs.x86_64-linux = overlays-combined // self.packages.x86_64-linux;
}
