{ lib, ... }:
{
  imports = [ ../generic ];

  home-manager.sharedModules = [
    {
      programs.nushell.extraConfig = ''
        def upgrade-system [
          --reboot (-r)
          --local-flake (-l)
        ] {
          let $url = hostname | if $local_flake { $".#($in)" } else { $"git+https://code.rmntn.net/iac/nix#($in)" }
          let $action = match $reboot {
            true => 'boot',
            false => 'switch'
          }
          sudo nixos-rebuild $action --flake $url
          upgrade-diff
          if $reboot {
            input -n 1 'Press any key when ready to reboot'
            sudo reboot
          }
        }
      '';
    }
  ];

  home-manager.users = {
    emergency = {
      programs.home-manager.enable = true;
    };
  };
}
