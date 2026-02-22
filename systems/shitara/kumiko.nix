{ flakeRoot, ... }:
{
  imports = [
    "${flakeRoot}/base/shitara/node.nix"
    "${flakeRoot}/home/inhouse"
  ];
  disabledModules = [ "${flakeRoot}/base/shitara/mopdc-tunnel.nix" ];
}
