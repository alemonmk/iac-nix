{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.vlmcsd =
    let
      inherit (lib.options) mkOption mkEnableOption;
      inherit (lib.types)
        nullOr
        bool
        str
        path
        ;
    in
    {
      enable = mkEnableOption "vlmcsd";

      listenAddr = mkOption {
        type = str;
        description = "Address to listen on.";
        default = "0.0.0.0:1688";
      };

      kmsDatabaseFile = mkOption {
        type = nullOr path;
        description = "Custom KMS database file.";
        default = null;
      };
    };

  config.systemd.services.vlmcsd =
    let
      inherit (lib.strings) concatStringSep;
      inherit (lib.lists) optional;
      cfg = config.services.vlmcsd;
      cmdline = concatStringSep " " (
        [ "${pkgs.vlmcsd}/bin/vlmcsd -Dev -d -t 5 -K3 -c1 -M1 -N1 -B1 -L ${cfg.listenAddr}" ]
        ++ optional (cfg.kmsDatabaseFile != null) "-j ${cfg.kmsDatabaseFile}"
      );
    in
    lib.modules.mkIf cfg.enable {
      description = "Portable open-source KMS Emulator";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      startLimitBurst = 5;
      serviceConfig = {
        ExecStart = cmdline;
        DynamicUser = true;
        RestartSec = 3;
        Restart = "on-failure";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        PrivateDevices = true;
        DevicePolicy = "strict";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        RestrictNamespaces = true;
        ProtectProc = "invisible";
        ProtectSystem = "full";
        ProtectClock = true;
        ProtectControlGroups = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };
    };
}
