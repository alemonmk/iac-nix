inputs: let
  inherit (inputs) self nixpkgs;
  inherit (self.lib) finalSystem finalLinodeSystem finalDarwinSystem;
  inherit (nixpkgs.lib) attrNames genAttrs mapAttrs filterAttrs map removeSuffix;
  inherit (builtins) readDir;

  systemByNameFolders = sysFunc: base:
    mapAttrs
    (
      n: _:
        sysFunc [
          "${base}/${n}/configuration.nix"
          {networking.hostName = n;}
        ]
    )
    (filterAttrs (k: v: v == "directory") (readDir base));

  systemByNameFiles = sysFunc: base:
    genAttrs
    (
      map
      (x: removeSuffix ".nix" x)
      (attrNames (filterAttrs (k: v: v == "regular") (readDir base)))
    )
    (
      n:
        sysFunc [
          "${base}/${n}.nix"
          {networking.hostName = n;}
        ]
    );

  inhouse = systemByNameFolders finalSystem ./inhouse;
  shitara = systemByNameFiles finalLinodeSystem ./shitara;
  nixos = inhouse // shitara;
  darwin = systemByNameFiles finalDarwinSystem ./darwin;
in {
  inherit nixos darwin;
}
