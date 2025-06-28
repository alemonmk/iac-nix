{
  config,
  lib,
  ...
}: {
  services = {
    grafana = {
      enable = true;
      settings = {
        server = {
          domain = "monitoring.noc.snct.rmntn.net";
          root_url = "https://%(domain)s";
          enforce_domain = true;
        };
        analytics.reporting_enabled = false;
        security = {
          admin_user = "system";
          disable_gravatar = true;
          cookie_secure = true;
        };
        users = {
          allow_sign_up = false;
          allow_org_create = false;
        };
        "auth.azuread" = {
          enabled = true;
          allow_sign_up = true;
          client_id = "$__file{${config.sops.secrets.entra-client-id.path}}";
          client_secret = "$__file{${config.sops.secrets.entra-client-secret.path}}";
          scopes = "openid email profile";
          auth_url = "https://login.microsoftonline.com/da34cce3-0860-45ae-bc8d-37725f6ecdfa/oauth2/v2.0/authorize";
          token_url = "https://login.microsoftonline.com/da34cce3-0860-45ae-bc8d-37725f6ecdfa/oauth2/v2.0/token";
          allowed_domains = "rmntn.net";
        };
      };
    };

    caddy.virtualHosts."monitoring.noc.snct.rmntn.net".extraConfig = lib.mkAfter ''
      handle {
          reverse_proxy 127.0.0.1:3000
      }
    '';
  };

  systemd.services.grafana.environment = {
    http_proxy = "http://10.85.20.10:3128";
    https_proxy = "http://10.85.20.10:3128";
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/grafana"];
}
