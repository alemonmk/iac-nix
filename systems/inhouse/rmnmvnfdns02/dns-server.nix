{
  services = {
    technitium-dns-server.enable = true;

    caddy.enable = true;
    caddy.virtualHosts."dns02.noc.snct.rmntn.net".extraConfig = ''
      reverse_proxy localhost:5380 {
            header_up X-Real-IP {remote_host}
      }
    '';
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/private/technitium-dns-server"];
}
