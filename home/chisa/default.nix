{
  config,
  pkgs,
  ...
}: {
  programs.home-manager.enable = true;
  home.stateVersion = "24.05";
  home.homeDirectory = "/Users/alemonmk";

  home.sessionVariables = {
    NOMAD_ADDR = "http://10.85.183.1:4646";
    CONSUL_HTTP_ADDR = "http://10.85.183.1:8500";
  };

  programs.zsh.enable = true;

  imports = [
    ./ssh.nix
    ./git.nix
    ./alacritty.nix
  ];
}
