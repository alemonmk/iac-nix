{ flakeRoot, ... }:
{
  imports = [
    "${flakeRoot}/base/shitara/node.nix"
    "${flakeRoot}/home/inhouse"
  ];
}
