{ self, ... }:
let
  inherit (self.lib)
    finalSystem
    finalLinodeSystem
    finalDarwinSystem
    forFoldersAsSystems
    forNixFilesAsSystems
    ;

  inhouse = ./inhouse |> forFoldersAsSystems finalSystem;
  shitara = ./shitara |> forFoldersAsSystems finalLinodeSystem;
  nixos = inhouse // shitara;
  darwin = ./darwin |> forNixFilesAsSystems finalDarwinSystem;
in
{
  inherit nixos darwin;
}
