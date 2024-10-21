{
  nixpkgs,
  system,
}: let
  pkgs = import nixpkgs {inherit system;};
in
  pkgs.mkShell {
    name = "Shell for working with sops";
    buildInputs = with pkgs; [ssh-to-age age sops];
  }
