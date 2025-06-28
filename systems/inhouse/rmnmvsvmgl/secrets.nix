{
  config,
  flakeRoot,
  ...
}:
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.nix-remote-sshkey = {
      mode = "0400";
      owner = config.users.users.code-server.name;
      group = config.users.users.code-server.group;
      sopsFile = "${flakeRoot}/secrets/svmgl/remote-sshkey.yaml";
    };
    secrets.ci-signing-key = {
      mode = "0440";
      group = config.users.users.hydra.group;
      sopsFile = "${flakeRoot}/secrets/svmgl/ci-signing-key.yaml";
    };
  };
}
