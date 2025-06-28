inputs:
let
  inherit (inputs) self nixpkgs nixpkgs-next;
  inherit (nixpkgs.lib) elem getName mapAttrs;
  pkgs-stable = import nixpkgs {
    system = "x86_64-linux";
    config.allowUnfree = true;
    config.allowInsecurePredicate = pkg: elem (getName pkg) [ "squid" ];
  };
  pkgs-next = nixpkgs-next.legacyPackages.x86_64-linux;
  stable-overlay-realised = (import ../overlays/stable.nix) pkgs-stable pkgs-stable;
  next-overlay-realised = (import ../overlays/next.nix) pkgs-next pkgs-next;
  overlays-combined = stable-overlay-realised // next-overlay-realised;
in
{
  hosts.x86_64-linux = mapAttrs (_: cfg: cfg.config.system.build.toplevel) self.nixosConfigurations;
  pkgs.x86_64-linux = overlays-combined // self.packages.x86_64-linux;
}
