{
  config,
  lib,
  ...
}:
{
  nix.registry = lib.mkForce { };
  system.installer.channel.enable = false;
  system.tools.nixos-option.enable = false;
  environment.ldso32 = null;
  services.dbus.implementation = "broker";
  security.pam.services.su.forwardXAuth = lib.mkForce false;
  documentation.enable = false;
  documentation.man.enable = lib.mkForce false;
  documentation.nixos.enable = lib.mkForce false;
  programs.nano.enable = false;
  security.sudo.enable = false;
  security.polkit.enable = lib.mkForce false;
  services.getty.autologinUser = lib.mkForce "root";
}
