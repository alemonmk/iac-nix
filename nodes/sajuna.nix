{...}: {
  imports = [./shitara/node.nix];
  disabledModules = [./shitara/mopdc-tunnel.nix];

  networking.hostName = "sajuna";
}
