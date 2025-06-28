{flakeRoot, ...}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.patroni-config = {
      mode = "0440";
      uid = 999;
      gid = 999;
      sopsFile = "${flakeRoot}/secrets/svadb02/patroni.yaml";
      key = "";
    };
  };
}
