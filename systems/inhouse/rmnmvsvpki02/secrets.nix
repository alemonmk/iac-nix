{
  config,
  flakeRoot,
  ...
}:
{
  sops = {
    secrets.w1-pkey-password = {
      owner = config.users.users.step-ca.name;
      sopsFile = "${flakeRoot}/secrets/svpki02/ca-w1.yaml";
    };
  };
}
