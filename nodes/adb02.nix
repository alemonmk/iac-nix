{
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  sops = {
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    secrets.patroni-config = {
      mode = "0440";
      uid = 999;
      gid = 999;
      sopsFile = ../secrets/adb02/patroni.yaml;
      key = "";
    };
  };

  networking = {
    hostName = "rmnmvadb02";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.66";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.126";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e4::39b:84e0";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e4::ccef";};
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };

  virtualisation.oci-containers.containers = {
    "pgsql-patroni" = {
      image = "ghcr.io/alemonmk/nomad-pgsql-patroni:17.4-1.tsdb_gis";
      extraOptions = ["--network=host"];
      environment = {
        POSTGRES_INITDB_ARGS = "--data-checksums";
      };
      volumes = [
        "/nix/persist/var/lib/postgresql:/var/lib/postgresql/data"
        "${config.sops.secrets.patroni-config.path}:/secrets/patroni.yml"
      ];
    };
  };

  services.etcd = {
    enable = true;
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/postgresql"
      "/var/lib/etcd"
    ];
  };
}
