{
  config,
  flakeRoot,
  ...
}: {
  services = {
    oxidized = {
      enable = true;
      configFile = config.sops.templates.oxidized-cfg.path;
      routerDB = "${flakeRoot}/blobs/monitoring/oxidized/routers.db";
    };

    caddy.virtualHosts."monitoring.noc.snct.rmntn.net".extraConfig = ''
      handle /ncm/* {
          reverse_proxy 127.0.0.1:8888
      }
    '';
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/oxidized/store"];
}
