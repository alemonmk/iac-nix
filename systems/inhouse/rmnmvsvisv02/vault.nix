{
  self,
  flakeRoot,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (builtins) hashFile;
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
  services.openbao = {
    enable = true;
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
      api_addr = "https://secrets.snct.rmntn.net";
      cluster_addr = "https://10.85.101.10:8201";
      cluster_name = "rmntn-secrets-1";
      max_lease_ttl = "12h";
      default_lease_ttl = "4h";
      user_lockout.all = {
        lockout_threshold = "3";
        lockout_duration = "30m";
        lockout_counter_reset = "15m";
      };
      storage.raft = {
        retry_join = [
          { leader_api_addr = "https://10.85.101.9:8200"; }
          { leader_api_addr = "https://10.85.101.10:8200"; }
          { leader_api_addr = "https://10.85.183.6:8200"; }
        ];
        path = "/var/lib/openbao";
      };
      plugin_directory = "${plugin_dir}/bin";
      plugin = [
        {
          secret.aws = {
            command = plugin-secrets-aws.meta.mainProgram;
            version = "v${plugin-secrets-aws.version}";
            binary_name = plugin-secrets-aws.meta.mainProgram;
            sha256sum = hashFile "sha256" (lib.meta.getExe plugin-secrets-aws);
          };
        }
        {
          secret.consul = {
            command = plugin-secrets-consul.meta.mainProgram;
            version = "v${plugin-secrets-consul.version}";
            binary_name = plugin-secrets-consul.meta.mainProgram;
            sha256sum = hashFile "sha256" (lib.meta.getExe plugin-secrets-consul);
          };
        }
        {
          secret.nomad = {
            command = plugin-secrets-nomad.meta.mainProgram;
            version = "v${plugin-secrets-nomad.version}";
            binary_name = plugin-secrets-nomad.meta.mainProgram;
            sha256sum = hashFile "sha256" (lib.meta.getExe plugin-secrets-nomad);
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

  services.caddy = {
    enable = true;
    virtualHosts."secrets.snct.rmntn.net".extraConfig = "reverse_proxy https://10.85.101.10:8200";
  };

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/var/lib/private/openbao";
      mode = "0700";
    }
  ];
}
