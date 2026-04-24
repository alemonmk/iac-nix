{
  self,
  flakeRoot,
  config,
  pkgs,
  ...
}:
{
  imports = [ self.nixosModules.vault-unseal ];

  services.openbao = {
    enable = true;
    package = pkgs.vault-bin;
    settings = {
      listener.default = {
        type = "tcp";
        address = "10.85.183.6:8200";
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
      cluster_addr = "10.85.183.6:8201";
      cluster_name = "rmntn-secrets-1";
      disable_mlock = true;
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
      ui = true;
    };
  };

  systemd.services.openbao.serviceConfig.LoadCredential =
    "tls-key:${config.sops.secrets.vault-mtls-key.path}";

  services.vault-unseal = {
    enable = true;
    configFile = config.sops.templates.auto-unseal-conf.path;
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname ne "eth0" ip daddr 10.85.183.6 tcp dport 8200 counter accept
      iifname ne "eth0" ip saddr {10.85.101.9, 10.85.101.10} ip daddr 10.85.183.6 tcp dport 8201 counter accept
    }
  '';
}
