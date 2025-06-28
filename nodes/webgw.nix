{
  config,
  lib,
  ...
}: {
  networking = {
    hostName = "rmnmvwebgw";
    proxy = lib.mkForce {
      httpProxy = null;
      httpsProxy = null;
    };
  };

  systemd.network.networks."1-ens192" = {
    matchConfig.Name = "ens192";
    address = [
      "10.85.20.10/26"
      "2400:8902:e002:59e3::403:9ae7/64"
    ];
    gateway = [
      "10.85.20.62"
      "2400:8902:e002:59e3::ccef"
    ];
    networkConfig.LLDP = false;
  };

  nixpkgs.config.allowInsecurePredicate = pkg: lib.elem (lib.getName pkg) ["squid"];

  environment.etc."squid/acl".source = ../blobs/squid/acl;
  systemd.services.squid.restartTriggers = [config.environment.etc."squid/acl".source];

  services = {
    squid = {
      enable = true;
      validateConfig = false;
      configText = lib.readFile ../blobs/squid/config;
    };
    syslog-ng = {
      enable = true;
      configHeader = ''
        @version: 4.8
        @include "scl.conf"
      '';
      extraConfig = ''
        log {
          source { system(); };
          filter { facility("local2"); };
          destination { syslog("rmnmvnocmt01.snct.rmntn.net" transport("tcp") port(3514)); };
        };
      '';
    };
  };
}
