{
  self,
  lib,
  ...
}:
{
  imports = lib.lists.flatten [
    ./base/node.nix
    (./kotone |> self.lib.forNixFilesAsModules |> lib.attrsets.attrValues)
  ];

  virtualisation.oci-containers.backend = "docker";

  services.consul.enable = false;
  services.nomad.enable = false;
}
