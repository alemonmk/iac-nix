{flakeRoot, ...}: {
  imports = ["${flakeRoot}/base/shitara/node.nix"];
  disabledModules = ["${flakeRoot}/base/shitara/mopdc-tunnel.nix"];
}
