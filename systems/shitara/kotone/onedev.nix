{ config, ... }:
{
  systemd.tmpfiles.settings = {
    "10-onedev"."/opt/onedev".d = {
      mode = "0700";
      user = "root";
      group = "root";
    };
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

  networking.nftables.tables = {
    global.content = ''
      chain service-input {
        iifname "ztinv*" ip daddr 10.85.183.6 tcp dport 6610 counter accept
      }
    '';
    nat.content = ''
      chain source-nat {
        iifname "docker0" oifname "eth0" ip saddr 172.17.0.0/16 counter masquerade
      }
    '';
  };
}
