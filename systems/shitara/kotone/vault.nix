{ self, ... }:
{
  imports = [
    self.nixosModules.vault-unseal
    self.nixosModules.secret-vault-cluster
  ];

  services.openbao = {
    enable = true;
    settings = {
      api_addr = "https://secrets.snct.rmntn.net";
      cluster_addr = "https://10.85.183.6:8201";
      cluster_name = "rmntn-secrets-1";
      storage.raft = {
        retry_join = [
          { leader_api_addr = "https://10.85.101.9:8200"; }
          { leader_api_addr = "https://10.85.101.10:8200"; }
          { leader_api_addr = "https://10.85.183.6:8200"; }
        ];
      };
    };
  };

  services.caddy = {
    virtualHosts."secrets.snct.rmntn.net" = {
      listenAddresses = [ "10.85.183.6" ];
      extraConfig = "reverse_proxy https://10.85.183.6:8200";
    };
  };

  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname ne "eth0" ip daddr 10.85.183.6 tcp dport 8200 counter accept
      iifname ne "eth0" ip saddr {10.85.101.9, 10.85.101.10} ip daddr 10.85.183.6 tcp dport 8201 counter accept
    }
  '';
}
