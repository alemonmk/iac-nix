{config, ...}: {
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
}
