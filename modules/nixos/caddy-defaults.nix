{
  config,
  lib,
  ...
}:
{
  config = lib.modules.mkIf config.services.caddy.enable {
    services = {
      caddy = {
        acmeCA = "https://atpki.snct.rmntn.net/acme/w1/directory";
        email = "apps@snct.rmntn.net";
        globalConfig = ''
          persist_config off
          key_type p256
        '';
        extraConfig = ''
          (cors) {
            @cors_preflight method OPTIONS
            @cors header Origin {args[0]}
            handle @cors_preflight {
              header Access-Control-Allow-Origin "{args[0]}"
              header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, DELETE"
              header Access-Control-Allow-Headers "Content-Type"
              header Access-Control-Max-Age "3600"
              respond "" 204
            }
            handle @cors {
              header Access-Control-Allow-Origin "{args[0]}"
              header Access-Control-Expose-Headers "Link"
            }
          }
        '';
      };
    };

    environment.persistence."/nix/persist".directories = [ "/var/lib/caddy/.local" ];
  };
}
