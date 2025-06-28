{
  services = {
    zerotierone = {
      enable = true;
      localConf = {
        physical."2400:8902:e002:5900::/56".blacklist = true;
        settings.softwareUpdate = "disable";
      };
      joinNetworks = ["1fdfc25cb4361829"];
    };

    bird = {
      enable = true;
      config = ''
        log syslog all;
        timeformat route iso long;
        timeformat protocol iso long;

        router id 10.85.29.3;
        ipv4 table master4;
        ipv6 table master6;

        protocol device {}
        protocol direct {
            interface "ztinv7ire5";
            ipv4;
            ipv6;
        }
        protocol kernel {
            ipv4;
        }
        protocol kernel {
            ipv6;
        }
        protocol bgp upstream_v4 {
            local 10.85.29.3 as 65407;
            neighbor 10.85.29.1 as 65405;
            keepalive time 20;
            hold time 60;
            graceful restart on;
            long lived graceful restart on;
            ipv4 {
                import all;
                export where net ~ 10.80.105.0/24;
            };
        }
        protocol bgp upstream_v6 {
            local 2400:8902:e002:59e9::8e01 as 65407;
            neighbor 2400:8902:e002:59e9::1 as 65405;
            keepalive time 20;
            hold time 60;
            graceful restart on;
            long lived graceful restart on;
            ipv6 {
                import all;
                export where net ~ 2400:8902:e002:59af::/64;
            };
        }
      '';
    };
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/zerotier-one"];
}
