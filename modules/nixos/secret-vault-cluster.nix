{
  self,
  flakeRoot,
  config,
  options,
  lib,
  pkgs,
  ...
}:
{
  config = lib.modules.mkIf config.services.openbao.enable {
    services.openbao.settings = {
      listener.default = {
        type = "tcp";
        address = "[::]:8200";
        x_forwarded_for_authorized_addrs = "127.0.0.1,10.85.183.0/28,10.91.145.32/28";
        tls_cert_file =
          (pkgs.writeTextFile {
            name = "vault-mtls-chain.crt";
            text = ''
              ${builtins.readFile (flakeRoot + /blobs/secrets-vault/mtls.crt)}
              ${builtins.readFile (flakeRoot + /blobs/pki/v1.crt)}
            '';
          }).outPath;
        tls_key_file = "/run/credentials/openbao.service/tls-key";
        tls_min_version = "tls13";
      };
      max_lease_ttl = "12h";
      default_lease_ttl = "4h";
      user_lockout.all = {
        lockout_threshold = "3";
        lockout_duration = "30m";
        lockout_counter_reset = "15m";
      };
      storage.raft.path = "/var/lib/openbao";
      plugin_directory = "/var/lib/private/openbao/plugins";
      plugin = [
        {
          secret.aws = {
            image = "ghcr.io/openbao/openbao-plugin-secrets-aws";
            version = "v0.3.0-beta20260326";
            binary_name = "openbao-plugin-secrets-aws";
            # obtained with `nix run nixpkgs#crane -- export <image> - | tar Oxf - | sha256sum`
            sha256sum = "9aaa8f2597f1bfa98a727a6230d9c7f62f096e1d25607fab3a9f9cc8ce48af7a";
          };
        }
        {
          secret.consul = {
            image = "ghcr.io/openbao/openbao-plugin-secrets-consul";
            version = "v0.1.0";
            binary_name = "openbao-plugin-secrets-consul";
            sha256sum = "5c5f662a7192aad87de37b82b7479c7b6e19d99ef021e8b80ce4d423a5fc8af1";
          };
        }
        {
          secret.nomad = {
            image = "ghcr.io/openbao/openbao-plugin-secrets-nomad";
            version = "v0.1.5";
            binary_name = "openbao-plugin-secrets-nomad";
            sha256sum = "a5df5663520e40bc1d0a6ed5a52e5bb2eab7c2de165f4cc9a0a2fce6604eae09";
          };
        }
      ];
      plugin_auto_download = true;
      plugin_auto_register = true;
      ui = true;
    };

    systemd.services.openbao = {
      environment = lib.optionalAttrs (config.networking.proxy.httpProxy != null) {
        http_proxy = config.networking.proxy.httpProxy;
        https_proxy = config.networking.proxy.httpsProxy;
        no_proxy = config.networking.proxy.noProxy;
      };
      serviceConfig = {
        LoadCredential = "tls-key:${config.sops.secrets.vault-mtls-key.path}";
        # Needed when running OCI plugins in StateDirectory
        # https://github.com/NixOS/nixpkgs/issues/513847
        ExecPaths = [ "/var/lib/openbao" ];
      };
    };

    services.vault-unseal = {
      enable = true;
      configFile = config.sops.templates.auto-unseal-conf.path;
    };

    environment = lib.attrsets.optionalAttrs (options.environment ? persistence) {
      persistence."/nix/persist".directories = [
        {
          directory = "/var/lib/private/openbao";
          mode = "0700";
        }
      ];
    };
  };
}
