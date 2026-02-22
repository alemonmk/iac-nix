{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.vpn-route-gen.enable = lib.options.mkEnableOption "vpn-route-gen";

  config.systemd = lib.modules.mkIf config.services.vpn-route-gen.enable {
    services.vpn-route-gen = {
      description = "Refresh internet prefixes to be rerouted via VPN";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = lib.meta.getExe pkgs.vpn-route-gen;
      };
    };
    timers.vpn-route-gen = {
      description = "Refresh internet prefixes to be rerouted via VPN every 6 hours";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "10s";
        OnUnitActiveSec = "6h";
      };
    };
  };
}
