{
  home.shellAliases = {
    ll = "eza -aalh -s type --git --git-repos";
    lt = "eza -lhT -s type --git --git-repos --git-ignore";
  };

  imports = [
    ./nushell.nix
    ./zsh.nix
    ./carapace.nix
    ./starship.nix
  ];
}
