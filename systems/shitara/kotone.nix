{
  flakeRoot,
  config,
  lib,
  pkgs,
  nixpkgs-next,
  ...
}:
{
  imports = [ ./base/node.nix ];

  sops.secrets = {
    onedev-dbpw.sopsFile = flakeRoot + /secrets/shitara/onedev-dbpw.yaml;
    dkimkey = {
      owner = config.users.users.dkimsign.name;
      sopsFile = flakeRoot + /secrets/shitara/kotone/dkimkey.yaml;
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
  services.consul.enable = false;
  services.nomad.enable = false;

  virtualisation.oci-containers.backend = "docker";

  systemd.tmpfiles.settings = {
    "10-hath"."/opt/hath/download".a = {
      argument = "d:u:emergency:rwx,u:emergency:rwx";
    };
    "10-onedev"."/opt/onedev".d = {
      mode = "0700";
      user = "root";
      group = "root";
    };
  };

  users.users.hath = {
    uid = 9999;
    group = "hath";
    isNormalUser = true;
    home = "/opt/hath";
  };
  users.groups.hath = {
    gid = 9999;
  };
  virtualisation.oci-containers.containers."hath" = {
    image = "frosty5689/hath:1.6.4";
    user = "9999:9999";
    networks = [ "host" ];
    capabilities.all = false;
    volumes = lib.lists.map (d: "/opt/hath/${d}:/hath/${d}") [
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
    package = nixpkgs-next.opensmtpd;
    procPackages = [ nixpkgs-next.opensmtpd-filter-dkimsign ];
    extraServerArgs = [ "-P mda" ];
    serverConfiguration =
      let
        netConfig = import (flakeRoot + /base/shitara/netconfigs.nix) config.networking.hostName;
        dkimSignCmd = lib.strings.concatStringsSep " " [
          "filter-dkimsign"
          "-t"
          "-c relaxed/relaxed"
          "-a rsa-sha256"
          "-d rmntn.net"
          "-s appmsgs"
          "-k ${config.sops.secrets.dkimkey.path}"
        ];
        dkimSignUser = config.users.users.dkimsign.name;
      in
      ''
        table cluster-net { 10.85.183.0/28, 10.91.145.32/28 }
        table outbound-src { ${netConfig.wan.v4} }
        filter dkim-sign proc-exec "${dkimSignCmd}" user ${dkimSignUser} group ${dkimSignUser}
        listen on socket filter "dkim-sign"
        listen on ${netConfig.lo} port 25 filter "dkim-sign"
        action "outbound" relay src <outbound-src>
        match from src <cluster-net> for any action "outbound"
      '';
  };

  services.vault = {
    enable = true;
    package = pkgs.vault-bin;
    address = "10.85.183.6:8200";
    listenerExtraConfig = ''
      x_forwarded_for_authorized_addrs = "10.85.183.0/28,10.91.145.32/28"
    '';
    storageBackend = "raft";
    storageConfig = ''
      retry_join { leader_api_addr = "http://rmnmvsvisv01.snct.rmntn.net:8200" }
      retry_join { leader_api_addr = "http://rmnmvsvisv02.snct.rmntn.net:8200" }
      retry_join { leader_api_addr = "http://10.85.183.6:8200" }
    '';
    extraConfig = ''
      ui = true
      disable_mlock = true
      api_addr = "http://10.85.183.6:8200"
      cluster_name = "rmntn-secvault-1"
      cluster_addr = "http://10.85.183.6:8201"
      default_lease_ttl = "4h"
      max_lease_ttl = "12h"
      user_lockout "all" {
        lockout_threshold = "3"
        lockout_duration = "30m"
        lockout_counter_reset = "15m"
      }
    '';
  };

  networking.nftables.tables = {
    global.content =
      let
        zerotierPort = toString config.services.zerotierone.port;
      in
      ''
        chain overlay-input {
          iifname "ztinv*" ip daddr 10.85.183.6 tcp dport ${zerotierPort} counter accept # Zerotier controller
        }
        chain service-input {
          iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 6610 counter accept # OneDev
          iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 25 counter accept # App mails
          iifname ne "eth0" ip daddr 10.85.183.6 tcp dport 8200 counter accept # Vault API
          iifname ne "eth0" ip saddr {10.85.101.9, 10.85.101.10} ip daddr 10.85.183.6 tcp dport 8201 counter accept # Vault cluster
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
