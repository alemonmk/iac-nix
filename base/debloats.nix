{
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
  fonts.fontconfig.enable = false;
  environment.ldso32 = null;
  environment.stub-ld.enable = false;
  boot.enableContainers = false;
  system.disableInstallerTools = true;
  system.tools = {
    nixos-rebuild.enable = true;
    nixos-version.enable = true;
  };
  documentation.enable = false;
  services.lvm.enable = false;
  programs.command-not-found.enable = false;
}
