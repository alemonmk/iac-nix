{ self, ... }:
let
  inherit (self.lib)
    finalSystem
    finalLinodeSystem
    finalDarwinSystem
    forFoldersAsSystems
    ;

  inhouse = ./inhouse |> forFoldersAsSystems finalSystem;
  shitara = ./shitara |> forFoldersAsSystems finalLinodeSystem;
  nixos = inhouse // shitara;
  darwin.chisa = finalDarwinSystem ./darwin/chisa.nix;
in
{
  inherit nixos darwin;
}
