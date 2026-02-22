{
  home.shell.enableShellIntegration = false;

  imports = [
    ./nushell.nix
    ./carapace.nix
    ./starship.nix
    ./vivid.nix
    ./zsh.nix
  ];
}
