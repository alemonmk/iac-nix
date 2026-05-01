{ flakeRoot, config, ... }:
{
  sops.secrets = {
    seaweedfs-security = {
      owner = config.users.users.seaweedfs.name;
      sopsFile = flakeRoot + /secrets/s3/security.yaml;
    };
  };
}
