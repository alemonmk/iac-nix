{
  virtualisation.oci-containers.backend = "docker";

  services.consul.enable = false;
  services.nomad.enable = false;

  services.caddy.enable = true;
  networking.nftables.tables.global.content = ''
    chain service-input {
      iifname ne "eth0" ip daddr 10.85.183.6 tcp dport 443 counter accept
    }
  '';
}
