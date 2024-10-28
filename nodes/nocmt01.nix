{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../base/configuration.nix
    ./nocmt01-telegraf.nix
  ];

  sops = {
    age.sshKeyPaths = ["/etc/sh/ssh_host_ed25519_key"];
    age.generateKey = true;
    secrets.entra-client-id = {
      mode = "0440";
      owner = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
      sopsFile = ../secrets/nocmt01/entraid.yaml;
    };
    secrets.entra-client-secret = {
      mode = "0440";
      owner = config.users.users.grafana.name;
      group = config.users.users.grafana.group;
      sopsFile = ../secrets/nocmt01/entraid.yaml;
    };
    secrets.ncm-password = {
      sopsFile = ../secrets/nocmt01/oxidized.yaml;
    };
    secrets.monitoring-creds = {
      mode = "0440";
      owner = config.users.users.telegraf.name;
      group = config.users.users.telegraf.group;
      sopsFile = ../secrets/nocmt01/monitoring.yaml;
    };
    templates."oxidized-cfg" = {
      file = ../blobs/monitoring/oxidized/config.yml;
      mode = "0440";
      owner = config.users.users.oxidized.name;
      group = config.users.users.oxidized.group;
    };
  };

  networking = {
    hostName = "rmnmvnocmt01";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.10.5";
        prefixLength = 27;
      }
    ];
    defaultGateway = {address = "10.85.10.30";};
    interfaces.ens224.ipv4.addresses = [
      {
        address = "10.88.0.2";
        prefixLength = 24;
      }
    ];
    enableIPv6 = false;
  };

  environment.systemPackages = with pkgs; [];

  networking.hosts = {
    "10.85.29.2" = ["vdi.snct.rmntn.net"];
  };

  services = {
    victoriametrics = {
      enable = true;
      retentionPeriod = 24;
      extraOptions = [
        "-selfScrapeInterval=15s"
        "-downsampling.period=90d:5m,365d:1h"
        "-promscrape.config.strictParse=false"
        "-promscrape.config=${../blobs/monitoring/victoriametrics/scrape.yml}"
      ];
    };

    prometheus.exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      configFile = ../blobs/monitoring/victoriametrics/blackbox.yml;
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          domain = "monitoring.noc.snct.rmntn.net";
          enforce_domain = true;
        };
        analytics.reporting_enabled = false;
        security = {
          admin_user = "system";
          disable_gravatar = true;
          cookie_secure = true;
        };
        users.editors_can_admin = true;
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

    oxidized = {
      enable = true;
      configFile = config.sops.templates.oxidized-cfg.path;
      routerDB = ../blobs/monitoring/oxidized/routers.db;
    };

    caddy = {
      enable = true;
      virtualHosts = {
        "monitoring.noc.snct.rmntn.net" = {
          extraConfig = ''
            handle /ncm/* {
                reverse_proxy 127.0.0.1:8888
            }
            handle {
                reverse_proxy 127.0.0.1:3000
            }
          '';
        };
      };
    };
  };

  environment.persistence."/nix/persist".directories = [
    "/var/lib/grafana"
    "/var/lib/oxidized/store"
    "/var/lib/victoriametrics"
  ];
}
