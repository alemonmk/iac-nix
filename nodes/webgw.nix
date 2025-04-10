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

  networking = {
    hostName = "rmnmvwebgw";
    interfaces.ens192.ipv4.addresses = [
      {
        address = "10.85.20.10";
        prefixLength = 26;
      }
    ];
    defaultGateway = {address = "10.85.20.62";};
    interfaces.ens192.ipv6.addresses = [
      {
        address = "2400:8902:e002:59e3::403:9ae7";
        prefixLength = 64;
      }
    ];
    defaultGateway6 = {address = "2400:8902:e002:59e3::ccef";};
    proxy = lib.mkForce {
      httpProxy = null;
      httpsProxy = null;
    };
  };

  environment.etc."squid/acl".source = ../blobs/squid/acl;

  services = {
    squid = {
      enable = true;
      package = nixpkgs-next.squid;
      configText = builtins.readFile ../blobs/squid/config;
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
