{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware.nix
    ../nix.nix
    ../security.nix
    ../debloats.nix
  ];

  system.stateVersion = "25.05";

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    domain = "rmntn.net";
    timeServers = [ "ats1.e-timing.ne.jp" ];
    useNetworkd = true;
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  boot.kernel.sysctl = {
    "net.core.wmem_max" = 134217728;
    "net.core.rmem_max" = 134217728;
    "net.ipv4.tcp_rmem" = "4096 87380 134217728";
    "net.ipv4.tcp_wmem" = "4096 65536 134217728";
    "net.core.netdev_max_backlog" = 30000;
    "net.ipv4.tcp_no_metrics_save" = 1;
    "net.core.default_qdisc" = "fq";
  };

  systemd.network.wait-online.enable = false;
  systemd.services.systemd-networkd.stopIfChanged = false;
  systemd.services.systemd-resolved.stopIfChanged = false;

  services.dbus.implementation = "broker";

  services.openssh.ports = [ 444 ];
  services.openssh.settings.PasswordAuthentication = false;

  users.users.emergency.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxdtPfxMfW1xKCbjVjpFZ+lF1XQYQn/a7TeSPSYD0TZ"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8AWxVE3RSe1WMh5Z3aEko4neJCilG+4/yHzYMJRGBc"
  ];
}
