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
    services.openbao =
      let
        plugin-secrets-aws = self.packages.x86_64-linux.openbao-plugins-secrets-aws;
        plugin-secrets-consul = self.packages.x86_64-linux.openbao-plugins-secrets-consul;
        plugin-secrets-nomad = self.packages.x86_64-linux.openbao-plugins-secrets-nomad;
        plugin_dir = pkgs.buildEnv {
          name = "openbao-plugins";
          paths = [
            plugin-secrets-aws
            plugin-secrets-consul
            plugin-secrets-nomad
          ];
        };
      in
      {
        settings = {
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
          plugin_directory = "${plugin_dir}/bin";
          plugin = [
            {
              secret.aws = {
                command = plugin-secrets-aws.meta.mainProgram;
                version = "v${plugin-secrets-aws.version}";
                binary_name = plugin-secrets-aws.meta.mainProgram;
                sha256sum = "d7ef575a9a2cee1717371832633b0b3ed301cf3e450e50720d0d378f82f57609";
              };
            }
            {
              secret.consul = {
                command = plugin-secrets-consul.meta.mainProgram;
                version = "v${plugin-secrets-consul.version}";
                binary_name = plugin-secrets-consul.meta.mainProgram;
                sha256sum = "573e9d73add0e4d861e0547a4be60d0e3b7d07df0e145e2b41b3817328bc516c";
              };
            }
            {
              secret.nomad = {
                command = plugin-secrets-nomad.meta.mainProgram;
                version = "v${plugin-secrets-nomad.version}";
                binary_name = plugin-secrets-nomad.meta.mainProgram;
                sha256sum = "adb5bc143a67b03b6e021a9d30de8629b52cd85714753c65a7fc0e24faf4e0ee";
              };
            }
          ];
          plugin_auto_download = false;
          plugin_auto_register = true;
          ui = true;
        };
      };

    systemd.services.openbao.serviceConfig.LoadCredential =
      "tls-key:${config.sops.secrets.vault-mtls-key.path}";

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
