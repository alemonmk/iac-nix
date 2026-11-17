{
  self,
  flakeRoot,
  config,
  options,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}:
{
  disabledModules = [ "services/security/openbao.nix" ];
  imports = [ "${self.inputs.nixpkgs-next}/nixos/modules/services/security/openbao.nix" ];

  config = lib.modules.mkIf config.services.openbao.enable {
    services.openbao.package = nixpkgs-next.openbao;
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
      plugins = [
        nixpkgs-next.openbaoPlugins.secrets-aws
        nixpkgs-next.openbaoPlugins.secrets-consul
        nixpkgs-next.openbaoPlugins.secrets-nomad
      ];
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
