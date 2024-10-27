{
  config,
  lib,
  ...
}: let
  cfg = config.services.caddy;
in {
  config = with lib;
    mkIf cfg.enable {
      services = {
        caddy = {
          acmeCA = "https://atpki.snct.rmntn.net/acme/w1/directory";
          email = "apps@snct.rmntn.net";
          globalConfig = ''
            admin off
            persist_config off
            key_type p256
          '';
        };
      };

      environment.persistence."/nix/persist".directories = ["/var/lib/caddy/.local"];
    };
}
