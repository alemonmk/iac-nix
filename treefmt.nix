{
  nixpkgs,
  treefmt-nix,
  ...
}:
let
  forEachSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "x86_64-darwin" ] f;

  settings = {
    projectRootFile = "flake.nix";
    settings.verbose = 1;
    settings.excludes = [
      "blobs/*"
      "secrets/*"
    ];

    programs.terraform.enable = true;
    programs.nixfmt.enable = true;
    programs.ruff-format.enable = true;
  };
  package = forEachSystems (sys: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${sys} settings);
in
forEachSystems (sys: package.${sys}.config.build.wrapper)
