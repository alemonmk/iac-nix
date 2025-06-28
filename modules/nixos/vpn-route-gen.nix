{
  config,
  lib,
  pkgs,
  ...
}: {
  config.systemd = {
    services.vpn-route-gen = {
      description = "Refresh internet prefixes to be rerouted via VPN";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = lib.getExe pkgs.vpn-route-gen;
      };
    };
    timers.vpn-route-gen = {
      description = "Refresh internet prefixes to be rerouted via VPN every 6 hours";
      timerConfig = {
        OnBootSec = "30s";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
