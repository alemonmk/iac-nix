{
  config,
  pkgs,
  flakeRoot,
  ...
}:
{
  sops = {
    secrets.entra-client-id = {
      owner = config.users.users.grafana.name;
      sopsFile = "${flakeRoot}/secrets/svnoc/entraid.yaml";
    };
    secrets.entra-client-secret = {
      owner = config.users.users.grafana.name;
      sopsFile = "${flakeRoot}/secrets/svnoc/entraid.yaml";
    };
    secrets.ncm-password.sopsFile = "${flakeRoot}/secrets/svnoc/oxidized.yaml";
    secrets.monitoring-creds = {
      owner = config.users.users.telegraf.name;
      sopsFile = "${flakeRoot}/secrets/svnoc/monitoring.yaml";
    };
    templates."oxidized-cfg" = {
      file = pkgs.replaceVarsWith {
        src = "${flakeRoot}/blobs/monitoring/oxidized/config.yml";
        replacements = {
          ncmPassword = config.sops.placeholder.ncm-password;
        };
      };
      owner = config.users.users.oxidized.name;
    };
  };
}
