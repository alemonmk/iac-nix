{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [./nocmt01-telegraf.nix];

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
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
      file = pkgs.replaceVarsWith {
        src = ../blobs/monitoring/oxidized/config.yml;
        replacements = {ncmPassword = config.sops.placeholder.ncm-password;};
      };
      mode = "0440";
      owner = config.users.users.oxidized.name;
      group = config.users.users.oxidized.group;
    };
  };

  networking = {
    hostName = "rmnmvnocmt01";
    hosts."10.85.29.2" = ["vdi.snct.rmntn.net"];
  };

  systemd.network.networks = {
    "1-ens192" = {
      matchConfig.Name = "ens192";
      address = ["10.85.10.5/27"];
      gateway = ["10.85.10.30"];
      networkConfig = {
        LLDP = false;
        IPv6AcceptRA = false;
      };
    };
    "2-ens224" = {
      matchConfig.Name = "ens224";
      address = ["10.88.0.2/24"];
    };
  };

  security.pki.certificateFiles = [
    ../blobs/pki/root_ca.crt
    ../blobs/pki/g1.crt
    ../blobs/pki/vmvcs.crt
  ];

  services = {
    victoriametrics = {
      enable = true;
      retentionPeriod = "2y";
      listenAddress = "localhost:8428";
      extraOptions = [
        "-selfScrapeInterval=15s"
        "-promscrape.config.strictParse=false"
        "-promscrape.config=${../blobs/monitoring/victoriametrics/scrape.yml}"
      ];
    };

    victorialogs = {
      enable = true;
      listenAddress = "localhost:9428";
      extraOptions = [
        "-retentionPeriod=26w"
        "-defaultMsgValue=none"
        "-syslog.listenAddr.tcp=localhost:3514"
      ];
    };

    syslog-ng = {
      enable = true;
      configHeader = ''
        @version: 4.8
        @include "scl.conf"
      '';
      extraConfig = builtins.readFile ../blobs/monitoring/log-forwarder.cfg;
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

  systemd.services.grafana.environment = {
    http_proxy = "http://10.85.20.10:3128";
    https_proxy = "http://10.85.20.10:3128";
  };

  environment.persistence."/nix/persist".directories = [
    "/var/lib/grafana"
    "/var/lib/oxidized/store"
    "/var/lib/private/victoriametrics"
    "/var/lib/private/victorialogs"
  ];
}
