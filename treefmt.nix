{
  nixpkgs,
  treefmt-nix,
  ...
}:
let
  forEachSystems = f: nixpkgs.lib.attrsets.genAttrs [ "x86_64-linux" "x86_64-darwin" ] f;

  settings = {
    projectRootFile = "flake.nix";
    settings.verbose = 1;
    settings.excludes = [
      ".gitignore"
      "secrets/*"
    ];
    settings.on-unmatched = "debug";

    programs = {
      terraform.enable = true;
      nixfmt.enable = true;
      jsonfmt.enable = true;
      ruff-format.enable = true;
      toml-sort.enable = true;
      yamlfmt = {
        enable = true;
        excludes = [ "blobs/monitoring/oxidized/config.yml" ];
        settings.formatter.retain_line_breaks = true;
      };
    };
  };
  package = forEachSystems (sys: treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${sys} settings);
in
forEachSystems (sys: package.${sys}.config.build.wrapper)
