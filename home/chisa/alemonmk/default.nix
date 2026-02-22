{
  home.sessionVariables = {
    NOMAD_ADDR = "http://10.85.183.1:4646";
    CONSUL_HTTP_ADDR = "http://10.85.183.1:8500";
    SOPS_AGE_KEY_FILE = "$HOME/.sops/key.txt";
  };
  home.sessionPath = [ "$HOME/.local/bin" ];

  imports = [
    ./ssh.nix
    ./git.nix
    ./alacritty.nix
  ];
}
