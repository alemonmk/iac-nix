{
  services.openbao = {
    enable = true;
    settings = {
      api_addr = "https://secrets.snct.rmntn.net";
      cluster_addr = "https://10.85.101.10:8201";
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
    enable = true;
    virtualHosts."secrets.snct.rmntn.net".extraConfig = "reverse_proxy https://10.85.101.10:8200";
  };
}
