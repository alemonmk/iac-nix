{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  networking = {
    hostName = "rmnmvnocmt01";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.10.5";
        prefixLength = 27;
      }
    ];
    defaultGateway = {address = "10.85.10.30";};
    enableIPv6 = false;
  };

  environment.systemPackages = with pkgs; [];

  services = {
    victoriametrics = {
      enable = true;
      retentionPeriod = 24;
      extraOptions = ["-selfScrapeInterval=15s"];
    };

    vmagent = {
      enable = true;
      remoteWrite.url = "http://localhost:8428/api/v1/write";
      prometheusConfig = builtins.fromJSON (builtins.readFile ../blobs/victoriametrics/scrape.json);
      extraArgs = ["-remoteWrite.tmpDataPath=/tmp/vmscrape"];
    };

    prometheus.exporters.blackbox = {
      enable = true;
      listenAddress = "127.0.0.1";
      configFile = ../blobs/victoriametrics/blackbox.yml;
    };

    networking.hosts = {
      "10.85.29.2" = ["vdi.snct.rmntn.net"];
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
          # client_id = config.sops.secrets.grafana.azuread-id;
          # client_secret = config.sops.secrets.grafana.azuread-secret;
          scopes = "openid email profile";
          auth_url = "https://login.microsoftonline.com/da34cce3-0860-45ae-bc8d-37725f6ecdfa/oauth2/v2.0/authorize";
          token_url = "https://login.microsoftonline.com/da34cce3-0860-45ae-bc8d-37725f6ecdfa/oauth2/v2.0/token";
          allowed_domains = "rmntn.net";
        };
      };
    };

    oxidized = {
      enable = true;
      # configFile = config.sops.secrets.oxidized.cfg.path;
      routerDB = ../blobs/oxidized/routers.db;
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
}
