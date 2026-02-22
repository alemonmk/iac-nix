{ lib, pkgs, ... }:
{
  programs.zsh = lib.modules.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    initContent = ''
      autoload - U promptinit && promptinit && setopt PROMPT_SP && setopt PROMPT_SUBST
      PROMPT="%n@%m %1~ %# "
      SHELL="zsh"
    '';
    history = {
      append = true;
      extended = true;
    };
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "eza";
      find = "fd -HIu";
    };
  };
}
