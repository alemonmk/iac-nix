{
  config,
  lib,
  flakeRoot,
  ...
}: {
  services = {
    victorialogs = {
      enable = true;
      listenAddress = "localhost:9428";
      extraOptions = [
        "-retentionPeriod=26w"
        "-defaultMsgValue=none"
        "-syslog.listenAddr.tcp=localhost:3514"
      ];
    };

    syslog-ng = {
      enable = true;
      configHeader = ''
        @version: 4.8
        @include "scl.conf"
      '';
      extraConfig = lib.readFile "${flakeRoot}/blobs/monitoring/log-forwarder.cfg";
    };
  };

  environment.persistence."/nix/persist".directories = ["/var/lib/private/victorialogs"];
}
