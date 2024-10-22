{
  config,
  options,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.prometheus.exporters.chrony;
in {
  options.services.prometheus.exporters.chrony = with lib; {
    enable = mkEnableOption "Prometheus Chrony exporter";

    package = mkPackageOption pkgs "prometheus-chrony-exporter" {};

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Listen address for Chrony exporter.";
    };

    port = mkOption {
      type = types.port;
      default = 9123;
      description = "Listen port for Chrony exporter.";
    };

    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [];
      example = ["--collector.sources"];
      description = ''
        Extra command line options to pass to MTR exporter.
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      users.users.chrony-exporter = {
        description = "Prometheus chrony exporter service user";
        isSystemUser = true;
        group = "chrony-exporter";
      };
      users.groups.chrony-exporter = {};

      systemd.services.chrony-exporter = {
        wantedBy = ["multi-user.target"];
        requires = ["network.target"];
        after = ["network.target"];
        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/chrony-exporter \
                --web.listen-address ${escapeShellArg "${cfg.address}:${toString cfg.port}"} \
                ${escapeShellArgs cfg.extraFlags}
          '';
          Restart = "on-failure";
          CapabilityBoundingSet = [""];
          DynamicUser = true;
          LockPersonality = true;
          ProcSubset = "pid";
          PrivateDevices = true;
          PrivateUsers = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "strict";
          RestrictNamespaces = true;
          RestrictRealtime = true;
        };
      };
    };
}
