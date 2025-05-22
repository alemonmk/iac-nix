{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ../base/configuration.nix
  ];

  networking = {
    hostName = "rmnmvntpsrv01";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.7";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.62";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e3::9:1a";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e3::ccef";};
  };

  services = {
    timesyncd.enable = false;
    chrony = {
      enable = true;
      servers = [
        "ats1.e-timing.ne.jp"
        "ntp1.nl.net"
        "ntp1.inrim.it"
        "ntp1.torix.ca"
        "ntp.ntu.edu.tw"
      ];
      serverOption = "iburst";
      extraConfig = ''
        makestep 1 -1
        leapsectz right/UTC
        local stratum 15 orphan
        binddevice ens192
        allow 10.0.0.0/8
        allow 2400:8902:e002:5900::/56
        authselectmode ignore
        bindcmdaddress 127.0.0.1
        cmdallow 127.0.0.1
        log tracking statistics
        ratelimit interval 1
      '';
    };
    prometheus.exporters.chrony = {
      enable = true;
      chronyServerAddress = "127.0.0.1:323";
      enabledCollectors = [
        "tracking"
        "sources"
        "serverstats"
        "dns-lookups"
      ];
      disabledCollectors = ["sources.with-ntpdata"];
    };
  };
}
