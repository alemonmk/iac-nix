{ lib, ... }:
{
  users.users.root.home = "/var/root";

  home-manager.users.root = {
    programs.home-manager.enable = true;
    home.stateVersion = "25.11";
    home.homeDirectory = "/var/root";

    home.sessionVariables = {
      EDITOR = "nano";
      SHELL = "nu";
      TERM = "xterm-256color";
    };

    imports = [
      ../shells
    ];

    programs.starship.settings.character = lib.mkForce {
      success_symbol = "[#](bold yellow)";
      error_symbol = "[#](bold red bg:white)";
    };
  };
}
