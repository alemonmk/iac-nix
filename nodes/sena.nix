{
  imports = [../base/shitara/node.nix];
  disabledModules = [../base/shitara/mopdc-tunnel.nix];

  networking.hostName = "sena";
}
