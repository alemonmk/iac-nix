{ nixpkgs-next, ... }:
{
  programs.carapace = {
    enable = true;
    package = nixpkgs-next.carapace;
    enableNushellIntegration = true;
    enableZshIntegration = false;
  };

  programs.nushell.extraConfig = ''
    $env.CARAPACE_BRIDGES = "zsh,bash"
  '';
}
