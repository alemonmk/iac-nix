{
  flakeRoot,
  config,
  pkgs,
  ...
}:
{
  services.openbao = {
    enable = true;
    package = pkgs.vault-bin;
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
      cluster_addr = "10.85.101.10:8201";
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

  services.caddy = {
    enable = true;
    virtualHosts."secrets.snct.rmntn.net".extraConfig = "reverse_proxy https://localhost:8200";
  };

  environment.persistence."/nix/persist".directories = [ "/var/lib/private/openbao" ];
}
