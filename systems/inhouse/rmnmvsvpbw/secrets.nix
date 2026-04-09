{ flakeRoot, ... }:
{
  sops = {
    secrets.smb-cred = {
      sopsFile = flakeRoot + /secrets/svadb02/smb.yaml;
    };
    secrets.pbw-env = {
      sopsFile = flakeRoot + /secrets/svadb02/pgbackweb.yaml;
    };
  };
}
