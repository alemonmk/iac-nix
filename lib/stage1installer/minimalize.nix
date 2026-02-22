{
  lib,
  ...
}:
let
  inherit (lib.modules) mkForce;
in
{
  nix.registry = mkForce { };
  system.installer.channel.enable = false;
  system.tools.nixos-option.enable = false;
  environment.ldso32 = null;
  services.dbus.implementation = "broker";
  security.pam.services.su.forwardXAuth = mkForce false;
  documentation.enable = false;
  documentation.man.enable = mkForce false;
  documentation.nixos.enable = mkForce false;
  programs.nano.enable = false;
  security.sudo.enable = false;
  security.polkit.enable = mkForce false;
  services.getty.autologinUser = mkForce "root";
}
