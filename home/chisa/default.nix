{
  users.users.alemonmk.home = "/Users/alemonmk";

  home-manager.users.alemonmk = {
    programs.home-manager.enable = true;
    imports = [ ./alemonmk ];
  };
}
