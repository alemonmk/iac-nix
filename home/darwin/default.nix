{ lib, ... }:
{
  imports = [ ../generic ];

  users.users.root.home = "/var/root";

  home-manager.sharedModules = [
    {
      home.sessionVariables = {
        EDITOR = "nano";
        TERM = "xterm-256color";
      };
      home.shellAliases = {
        ll = "eza -aalh -s type --git --git-repos";
        lt = "eza -lhT -s type --git --git-repos --git-ignore";
      };
      programs.nushell = {
        shellAliases = {
          nopen = "open";
          open = "^open";
        };
        extraConfig = ''
          path add -a /run/current-system/sw/bin

          def upgrade-system [--local-flake (-l)] {
            let $url = hostname | if $local_flake { $".#($in)" } else { $"git+https://code.rmntn.net/iac/nix#($in)" }
            sudo darwin-rebuild switch --flake $url
            upgrade-diff
          }
        '';
      };
    }
  ];
}
