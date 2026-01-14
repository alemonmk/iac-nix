{ config, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  virtualisation.oci-containers.containers = {
    "pgsql-patroni" = {
      image = "ghcr.io/alemonmk/nomad-pgsql-patroni:17.7-1.tsdb_gis";
      networks = [ "host" ];
      environment.POSTGRES_INITDB_ARGS = "--data-checksums";
      volumes = [
        "/nix/persist/var/lib/postgresql:/var/lib/postgresql/data"
        "${config.sops.secrets.patroni-config.path}:/secrets/patroni.yml"
      ];
    };
  };

  services.etcd.enable = true;

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
      "/var/lib/etcd"
    ];
  };
}
