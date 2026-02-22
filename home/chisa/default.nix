{ lib, ... }:
{
  users.users = {
    alemonmk.home = "/Users/alemonmk";
    root.home = "/var/root";
  };

  home-manager = {
    sharedModules = [
      {
        home.stateVersion = "25.11";
        home.sessionVariables = {
          EDITOR = "nano";
          TERM = "xterm-256color";
        };
        home.shellAliases = {
          ll = "eza -aalh -s type --git --git-repos";
          lt = "eza -lhT -s type --git --git-repos --git-ignore";
        };
      }
      ../shells
    ];

    users = lib.attrsets.mapAttrs (_: v: { programs.home-manager.enable = true; } // v) {
      root = {
        programs.starship.settings.character = lib.mkForce {
          success_symbol = "[#](bold yellow)";
          error_symbol = "[#](bold red bg:white)";
        };
      };
      alemonmk = {
        imports = [ ./alemonmk ];
      };
    };
  };
}
