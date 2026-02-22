{ nixpkgs-next, ... }:
{
  programs.carapace = {
    enable = true;
    package = nixpkgs-next.carapace;
    enableNushellIntegration = true;
  };

  programs.nushell.extraConfig = ''
    $env.CARAPACE_BRIDGES = "zsh,bash"
  '';
}
