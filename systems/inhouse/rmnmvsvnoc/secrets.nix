{
  config,
  pkgs,
  flakeRoot,
  ...
}: {
  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.entra-client-id = {
      mode = "0440";
      owner = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
      sopsFile = "${flakeRoot}/secrets/svnoc/entraid.yaml";
    };
    secrets.entra-client-secret = {
      mode = "0440";
      owner = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
      sopsFile = "${flakeRoot}/secrets/svnoc/entraid.yaml";
    };
    secrets.ncm-password.sopsFile = "${flakeRoot}/secrets/svnoc/oxidized.yaml";
    secrets.monitoring-creds = {
      mode = "0440";
      owner = config.users.users.telegraf.name;
      group = config.users.users.telegraf.group;
      sopsFile = "${flakeRoot}/secrets/svnoc/monitoring.yaml";
    };
    templates."oxidized-cfg" = {
      file = pkgs.replaceVarsWith {
        src = "${flakeRoot}/blobs/monitoring/oxidized/config.yml";
        replacements = {ncmPassword = config.sops.placeholder.ncm-password;};
      };
      mode = "0440";
      owner = config.users.users.oxidized.name;
      group = config.users.users.oxidized.group;
    };
  };
}
