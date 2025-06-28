{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.vpn-route-gen.enable = lib.mkEnableOption "vpn-route-gen";

  config.systemd = lib.mkIf config.services.vpn-route-gen.enable {
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
        OnBootSec = "10s";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
