{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  environment.systemPackages = [ pkgs.cifs-utils ];

  fileSystems."/mnt/BackupPGDB" = {
    device = "//rmnmpfss01.snct.rmntn.net/BackupPGDB";
    fsType = "cifs";
    options = [
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5s"
      "x-systemd.mount-timeout=5s"
      "vers=3"
      "credentials=${config.sops.secrets.smb-cred.path}"
      "uid=${toString config.users.users.pgbackweb.uid}"
    ];
  };

  users.users.pgbackweb = {
    isSystemUser = true;
    uid = 500;
    group = "pgbackweb";
  };
  users.groups.pgbackweb = { };

  virtualisation.oci-containers.containers = {
    "pgbackweb" = {
      image = "code.rmntn.net/containerized/pgbackweb/pgbackweb:v0.5.1-parade0.21.16";
      networks = [ "host" ];
      user = "${toString config.users.users.pgbackweb.uid}";
      environment = {
        PBW_LISTEN_HOST = "127.0.0.1";
        PBW_POSTGRES_CONN_STRING = "postgresql://pgbackweb@localhost/pgbackweb?sslmode=disable";
      };
      environmentFiles = [ config.sops.secrets.pbw-env.path ];
      volumes = [ "/mnt/BackupPGDB:/backups" ];
    };
  };

  services.caddy = {
    enable = true;
    virtualHosts."pgbu.snct.rmntn.net".extraConfig = "reverse_proxy localhost:8085";
  };

  services.postgresql = {
    enable = true;
    authentication = "host sameuser pgbackweb localhost trust";
    initdbArgs = [ "--data-checksums" ];
    ensureDatabases = [ "pgbackweb" ];
    ensureUsers = [
      {
        name = "pgbackweb";
        ensureDBOwnership = true;
      }
    ];
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
    ];
  };
}
