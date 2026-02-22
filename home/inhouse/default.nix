{ lib, ... }:
{
  home-manager = {
    sharedModules = [
      { home.stateVersion = "25.11"; }
      ../shells
    ];

    users = lib.attrsets.mapAttrs (_: v: { programs.home-manager.enable = true; } // v) {
      root = {
        programs.starship.settings.character = lib.modules.mkForce {
          success_symbol = "[#](bold yellow)";
          error_symbol = "[#](bold red bg:white)";
        };
      };
      emergency = { };
    };
  };
}
