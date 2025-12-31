{
  config,
  lib,
  pkgs,
  flakeRoot,
  ...
}:
{
  imports = [ "${flakeRoot}/base/shitara/node.nix" ];

  sops.secrets = {
    onedev-dbpw.sopsFile = "${flakeRoot}/secrets/shitara/onedev-dbpw.yaml";
    dkimkey = {
      owner = config.users.users.dkimsign.name;
      sopsFile = "${flakeRoot}/secrets/shitara/kotone/dkimkey.yaml";
    };
  };

  fileSystems."/opt/hath" = {
    device = "/dev/disk/by-id/scsi-0Linode_Volume_hath";
    fsType = "ext4";
  };

  services.zerotierone.localConf.settings.allowManagementFrom = [
    "10.85.183.0/24"
    "10.91.145.32/28"
  ];
  services.consul.enable = lib.mkForce false;
  services.nomad.enable = lib.mkForce false;

  virtualisation.oci-containers.backend = "docker";

  users.users.hath = {
    uid = 9999;
    group = "hath";
    isNormalUser = true;
    home = "/opt/hath";
  };
  users.groups.hath = {
    gid = 9999;
  };
  systemd.tmpfiles.settings = {
    "10-hath"."/opt/hath/download"."a".argument = "d:u:emergency:rwx,u:emergency:rwx";
  };
  virtualisation.oci-containers.containers."hath" = {
    image = "frosty5689/hath:1.6.4";
    user = "9999:9999";
    networks = [ "host" ];
    capabilities.all = false;
    volumes = lib.map (d: "/opt/hath/${d}:/hath/${d}") [
      "cache"
      "data"
      "download"
      "log"
      "tmp"
    ];
  };

  virtualisation.oci-containers.containers."onedev" = {
    image = "1dev/server:13.1.7";
    networks = [ "host" ];
    capabilities.all = false;
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

  users.users.dkimsign = {
    group = "dkimsign";
    isSystemUser = true;
  };
  users.groups.dkimsign = { };

  services.opensmtpd = {
    enable = true;
    setSendmail = false;
    extraServerArgs = [ "-P mda" ];
    serverConfiguration =
      let
        netConfig = import "${flakeRoot}/base/shitara/netconfigs.nix" {
          inherit (config.networking) hostName;
        };
        dkimsignuser = config.users.users.dkimsign.name;
      in
      ''
        table cluster-net { 10.85.183.0/28, 10.91.145.32/28 }
        table outbound-src { ${netConfig.wan.v4} }
        filter dkim-sign proc-exec "${pkgs.opensmtpd-filter-dkimsign}/libexec/opensmtpd/filter-dkimsign -t -c relaxed/relaxed -a rsa-sha256 -d rmntn.net -s appmsgs -k ${config.sops.secrets.dkimkey.path}" user ${dkimsignuser} group ${dkimsignuser}
        listen on socket filter "dkim-sign"
        listen on ${netConfig.lo} port 25 filter "dkim-sign"
        action "outbound" relay src <outbound-src>
        match from src <cluster-net> for any action "outbound"
      '';
  };

  networking.nftables.tables = {
    global.content = ''
      chain overlay-input {
        iifname "ztinv*" ip daddr 10.85.183.6 tcp dport ${toString config.services.zerotierone.port} counter accept # Zerotier controller
      }
      chain service-input {
        iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 6610 counter accept # OneDev
        iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 25 counter accept # App mails
        iifname "eth0" tcp dport 8472 counter accept # HatH
      }
    '';
    nat.content = ''
      chain source-nat {
        iifname "docker0" oifname "eth0" ip saddr 172.17.0.0/16 counter masquerade
      }
    '';
  };
}
