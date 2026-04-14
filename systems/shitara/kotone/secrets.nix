{
  flakeRoot,
  config,
  ...
}:
{
  sops.secrets = {
    onedev-dbpw.sopsFile = flakeRoot + /secrets/shitara/onedev-dbpw.yaml;
    dkimkey = {
      owner = config.users.users.dkimsign.name;
      sopsFile = flakeRoot + /secrets/shitara/kotone/dkimkey.yaml;
    };
  };
}
