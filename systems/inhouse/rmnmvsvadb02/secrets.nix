{ flakeRoot, ... }:
{
  sops = {
    secrets.patroni-config = {
      mode = "0440";
      uid = 999;
      gid = 999;
      sopsFile = "${flakeRoot}/secrets/svadb02/patroni.yaml";
      key = "";
    };
  };
}
