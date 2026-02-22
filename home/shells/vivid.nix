{ nixpkgs-next, ... }:
{
  programs.vivid = {
    enable = true;
    package = nixpkgs-next.vivid;
    # enableNushellIntegration = true;
    activeTheme = "catppuccin-latte";
  };
}
