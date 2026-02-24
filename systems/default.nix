inputs:
let
  inherit (inputs.self.lib) finalSystem finalLinodeSystem finalDarwinSystem;
  inherit (inputs.nixpkgs.lib.attrsets)
    attrNames
    genAttrs
    mapAttrs
    filterAttrs
    ;
  inherit (inputs.nixpkgs.lib.lists) map;
  inherit (inputs.nixpkgs.lib.strings) removeSuffix;
  inherit (builtins) readDir;

  systemByNameFolders =
    sysFunc: base:
    mapAttrs (
      n: _:
      sysFunc [
        { networking.hostName = n; }
        "${base}/${n}/configuration.nix"
      ]
    ) (filterAttrs (k: v: v == "directory") (readDir base));

  systemByNameFiles =
    sysFunc: base:
    genAttrs
      (map (x: removeSuffix ".nix" x) (attrNames (filterAttrs (k: v: v == "regular") (readDir base))))
      (
        n:
        sysFunc [
          { networking.hostName = n; }
          "${base}/${n}.nix"
        ]
      );

  inhouse = systemByNameFolders finalSystem ./inhouse;
  shitara = systemByNameFiles finalLinodeSystem ./shitara;
  nixos = inhouse // shitara;
  darwin = systemByNameFiles finalDarwinSystem ./darwin;
in
{
  inherit nixos darwin;
}
