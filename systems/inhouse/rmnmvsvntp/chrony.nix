{
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
