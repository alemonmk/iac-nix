{
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}:
let
  inherit (lib.strings) replaceStrings concatMapStringsSep optionalString;
  resolvePath =
    s: replaceStrings [ "$HOME" "$USER" ] [ config.home.homeDirectory config.home.username ] s;
  toNushellPathAdds = p: concatMapStringsSep "\n" (s: "path add `" + (resolvePath s) + "`") p;
in
{
  programs.nushell = {
    enable = true;
    package = nixpkgs-next.nushell;
    shellAliases = {
      nopen = "open";
      open = "^open";
    };
    settings = {
      buffer_editor = "nano";
      show_banner = false;
      float_precision = 2;
      bracketed_paste = true;
      use_ansi_coloring = true;
      completions.external.enable = true;
      filesize.unit = "metric";
      filesize.precision = 2;
      ls.use_ls_colors = true;
      table = {
        mode = "light";
        index_mode = "auto";
        show_empty = false;
      };
    };
    environmentVariables = {
      SHELL = "nu";
      LS_COLORS = lib.hm.nushell.mkNushellInline "${config.programs.vivid.package}/bin/vivid generate ${config.programs.vivid.activeTheme}";
    };
    extraConfig = ''
      const NU_LIB_DIRS = [
        "${nixpkgs-next.nu_scripts}/share/nu_scripts"
      ]

      use std/util "path add"                       # Add paths using std path add (prepends by default)
      path add "/usr/local/bin"                     # Standard UNIX paths (add first = lower priority)
      path add "/nix/var/nix/profiles/default/bin"  # Nix paths (add last = higher priority)
      path add "/run/current-system/sw/bin"

      use themes/nu-themes/catppuccin-latte.nu
      $env.config.color_config = (catppuccin-latte)

      use std/dirs
      use std/dirs shells-aliases *

      def upgrade-diff [] {
        ls -lDf /nix/var/nix/profiles/system-*-link
        | sort-by created 
        | last 2
        | get name
        | ${lib.meta.getExe pkgs.nvd} diff ...$in
      }
    ''
    + optionalString pkgs.stdenv.isLinux ''
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
    ''
    + optionalString pkgs.stdenv.isDarwin ''
      def upgrade-system [--local-flake (-l)] {
        let $url = hostname | if $local_flake { $".#($in)" } else { $"git+https://code.rmntn.net/iac/nix#($in)" }
        sudo darwin-rebuild switch --flake $url
        upgrade-diff
      }
    '';
    extraLogin = ''
      load-env ${lib.hm.nushell.toNushell { } config.home.sessionVariables}
      path add ($env.HOME | path join ".nix-profile" "bin")
      ${toNushellPathAdds config.home.sessionPath}
    '';
  };
}
