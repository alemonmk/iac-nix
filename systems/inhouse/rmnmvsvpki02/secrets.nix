{
  config,
  flakeRoot,
  ...
}:
{
  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets.w1-pkey-password = {
      mode = "0440";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
      sopsFile = "${flakeRoot}/secrets/svpki02/ca-w1.yaml";
    };
  };
}
