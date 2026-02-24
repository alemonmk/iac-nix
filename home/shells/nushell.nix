{
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}:
let
  inherit (lib.strings) replaceStrings concatMapStringsSep optionalString;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.hm.nushell) mkNushellInline;
  resolvePath =
    s: replaceStrings [ "$HOME" "$USER" ] [ config.home.homeDirectory config.home.username ] s;
  toNushellPathAdds = p: concatMapStringsSep "\n" (s: "path add `" + (resolvePath s) + "`") p;
in
{
  programs.nushell = {
    enable = true;
    package = nixpkgs-next.nushell;
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
      LS_COLORS = mkNushellInline "${config.programs.vivid.package}/bin/vivid generate ${config.programs.vivid.activeTheme}";
    };
    extraConfig = ''
      const NU_LIB_DIRS = [
        "${nixpkgs-next.nu_scripts}/share/nu_scripts"
      ]

      use themes/nu-themes/catppuccin-latte.nu
      $env.config.color_config = (catppuccin-latte)

      use std/util "path add"
      use std/dirs
      use std/dirs shells-aliases *

      def upgrade-diff [] {
        ls -lDf /nix/var/nix/profiles/system-*-link
        | sort-by created 
        | last 2
        | get name
        | ${lib.meta.getExe pkgs.nvd} diff ...$in
      }
    '';
    extraLogin = ''
      load-env ${lib.hm.nushell.toNushell { } config.home.sessionVariables}
      path add ($env.HOME | path join ".nix-profile" "bin")
      ${toNushellPathAdds config.home.sessionPath}
    '';
  };
}
