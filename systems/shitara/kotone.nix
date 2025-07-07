{
  config,
  lib,
  flakeRoot,
  ...
}:
{
  imports = [ "${flakeRoot}/base/shitara/node.nix" ];

  sops.secrets.onedev-dbpw.sopsFile = "${flakeRoot}/secrets/shitara/onedev-dbpw.yaml";

  fileSystems."/opt/hath" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_hath";
    fsType = "ext4";
  };

  users.users.hath = {
    uid = 9999;
    group = "hath";
    isNormalUser = true;
    createHome = false;
    home = "/opt/hath";
  };
  users.groups.hath = {
    gid = 9999;
  };
  systemd.tmpfiles.settings = {
    "10-hath"."/opt/hath/download"."a+".argument = "u:emergency:rwx";
  };

  services.zerotierone.localConf.settings.allowManagementFrom = [
    "10.85.183.0/24"
    "10.91.145.32/28"
  ];
  services.consul.enable = lib.mkForce false;
  services.nomad.enable = lib.mkForce false;

  virtualisation.oci-containers = {
    backend = "docker";
    containers =
      let
        commonOptions = {
          networks = [ "host" ];
          capabilities = {
            all = false;
          };
        };
      in
      lib.attrsets.mapAttrs (_: c: commonOptions // c) {
        "onedev" = {
          image = "1dev/server:11.11.4";
          environment = {
            hibernate_dialect = "io.onedev.server.persistence.PostgreSQLDialect";
            hibernate_connection_driver_class = "org.postgresql.Driver";
            hibernate_connection_url = "jdbc:postgresql://primary.pg-ha-1.service.consul:5432/onedev";
            hibernate_connection_username = "onedev";
            hibernate_connection_password_file = "/secrets/onedev-dbpw";
          };
          volumes = [
            "/run/docker.sock:/var/run/docker.sock"
            "/opt/onedev/data:/opt/onedev"
            "${config.sops.secrets.onedev-dbpw.path}:/secrets/onedev-dbpw"
          ];
        };
        "hath" = {
          image = "frosty5689/hath:1.6.4";
          user = "9999:9999";
          volumes = lib.map (d: "/opt/hath/${d}:/hath/${d}") [
            "cache"
            "data"
            "download"
            "log"
            "tmp"
          ];
        };
      };
  };

  networking.nftables.tables.global.content = ''
    chain overlay-input {
      iifname "ztinv*" ip daddr 10.85.183.6 tcp dport ${toString config.services.zerotierone.port} counter accept # Zerotier controller
    }
    chain service-input {
      iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 6610 counter accept # OneDev
      iifname "eth0" tcp dport 8472 counter accept # HatH
    }
  '';
}
