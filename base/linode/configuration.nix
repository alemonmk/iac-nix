{
  config,
  lib,
  pkgs,
  ...
}: {
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
    timeServers = ["ats1.e-timing.ne.jp"];
    useDHCP = false;
    usePredictableInterfaceNames = false;
  };

  services.dbus.implementation = "broker";

  services.openssh.ports = [444];
  users.users.emergency.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxdtPfxMfW1xKCbjVjpFZ+lF1XQYQn/a7TeSPSYD0TZ"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA8AWxVE3RSe1WMh5Z3aEko4neJCilG+4/yHzYMJRGBc"
  ];
}
