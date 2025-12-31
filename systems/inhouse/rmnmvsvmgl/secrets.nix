{
  config,
  flakeRoot,
  ...
}:
{
  sops = {
    secrets.nix-remote-sshkey = {
      owner = config.users.users.code-server.name;
      sopsFile = "${flakeRoot}/secrets/svmgl/remote-sshkey.yaml";
    };
    secrets.ci-signing-key = {
      mode = "0440";
      group = config.users.users.hydra.group;
      sopsFile = "${flakeRoot}/secrets/svmgl/ci-signing-key.yaml";
    };
  };
}
