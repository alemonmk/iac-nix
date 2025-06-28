{ nixpkgs, ... }:
let
  inherit (nixpkgs.lib)
    attrNames
    genAttrs
    filterAttrs
    map
    removeSuffix
    ;
  inherit (builtins) readDir attrValues;
in
genAttrs (map (x: removeSuffix ".nix" x) (
  attrNames (filterAttrs (k: v: k != "default.nix" && v == "regular") (readDir ./.))
)) (n: ./${n}.nix)
