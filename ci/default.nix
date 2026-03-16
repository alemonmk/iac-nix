{
  self,
  nixpkgs,
  nixpkgs-next,
  ...
}:
let
  inherit (nixpkgs.lib.lists) elem;
  inherit (nixpkgs.lib.strings) getName;
  inherit (nixpkgs.lib.attrsets) mapAttrs;

  pkgs-stable = import nixpkgs {
    localSystem = "x86_64-linux";
    config.allowUnfree = true;
    config.allowInsecurePredicate = pkg: elem (getName pkg) [ "squid" ];
  };
  pkgs-next = nixpkgs-next.legacyPackages.x86_64-linux;
  stable-overlay-realised = (import ../overlays/stable.nix) { } pkgs-stable;
  next-overlay-realised = (import ../overlays/next.nix) { } pkgs-next;
  overlays-combined = stable-overlay-realised // next-overlay-realised;
in
{
  hosts.x86_64-linux =
    self.nixosConfigurations |> mapAttrs (_: cfg: cfg.config.system.build.toplevel);
  pkgs.x86_64-linux = overlays-combined // self.packages.x86_64-linux;
}
