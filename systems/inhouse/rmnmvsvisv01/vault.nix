{
  config,
  lib,
  pkgs,
  ...
}:
{
  services = {
    vault = {
      enable = true;
      package = pkgs.vault-bin;
      address = "[::]:8200";
      listenerExtraConfig = ''
        x_forwarded_for_authorized_addrs = "10.85.183.0/28,10.91.145.32/28"
      '';
      storageBackend = "raft";
      storageConfig = ''
        retry_join { leader_api_addr = "http://rmnmvsvisv01.snct.rmntn.net:8200" }
        retry_join { leader_api_addr = "http://rmnmvsvisv02.snct.rmntn.net:8200" }
        retry_join { leader_api_addr = "http://10.85.183.6:8200" }
      '';
      extraConfig = ''
        ui = true
        disable_mlock = true
        api_addr = "http://rmnmvsvisv01.scnt.rmntn.net:8200"
        cluster_name = "rmntn-secvault-1"
        cluster_addr = "http://rmnmvsvisv01.snct.rmntn.net:8201"
        default_lease_ttl = "4h"
        max_lease_ttl = "12h"
        user_lockout "all" {
          lockout_threshold = "3"
          lockout_duration = "30m"
          lockout_counter_reset = "15m"
        }
      '';
    };
  };

  environment.persistence."/nix/persist".directories = [ "/var/lib/vault" ];
}
