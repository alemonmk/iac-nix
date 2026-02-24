inputs:
let
  inherit (inputs.self.lib)
    finalSystem
    finalLinodeSystem
    finalDarwinSystem
    forFoldersAsSystems
    forNixFilesAsSystems
    ;

  inhouse = ./inhouse |> forFoldersAsSystems finalSystem;
  shitara = ./shitara |> forNixFilesAsSystems finalLinodeSystem;
  nixos = inhouse // shitara;
  darwin = ./darwin |> forNixFilesAsSystems finalDarwinSystem;
in
{
  inherit nixos darwin;
}
