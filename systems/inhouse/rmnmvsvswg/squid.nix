{
  config,
  lib,
  flakeRoot,
  ...
}:
{
  nixpkgs.config.allowInsecurePredicate = pkg: lib.lists.elem (lib.meta.getName pkg) [ "squid" ];

  networking.proxy = {
    httpProxy = null;
    httpsProxy = null;
  };

  environment.etc."squid/acl".source = "${flakeRoot}/blobs/squid/acl";
  systemd.services.squid.restartTriggers = [ config.environment.etc."squid/acl".source ];

  services = {
    squid = {
      enable = true;
      validateConfig = false;
      configText = lib.trivial.readFile "${flakeRoot}/blobs/squid/config";
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
          destination { syslog("rmnmvsvnoc.snct.rmntn.net" transport("tcp") port(3514)); };
        };
      '';
    };
  };
}
