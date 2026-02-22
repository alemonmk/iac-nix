inputs:
let
  inherit (inputs.self.lib) finalSystem finalLinodeSystem finalDarwinSystem;
  inherit (inputs.nixpkgs.lib)
    attrNames
    genAttrs
    mapAttrs
    filterAttrs
    map
    removeSuffix
    ;
  inherit (builtins) readDir;

  homeManagerGlobalConfig =
    { nixpkgs-next, ... }:
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = false;
        extraSpecialArgs = { inherit nixpkgs-next; };
      };
    };

  systemByNameFolders =
    sysFunc: base:
    mapAttrs (
      n: _:
      sysFunc [
        homeManagerGlobalConfig
        { networking.hostName = n; }
        "${base}/${n}/configuration.nix"
        ../home/inhouse
      ]
    ) (filterAttrs (k: v: v == "directory") (readDir base));

  systemByNameFiles =
    sysFunc: base:
    genAttrs
      (map (x: removeSuffix ".nix" x) (attrNames (filterAttrs (k: v: v == "regular") (readDir base))))
      (
        n:
        sysFunc [
          homeManagerGlobalConfig
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
