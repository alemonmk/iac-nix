{ lib, nixpkgs-next, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = false;
    extraSpecialArgs = { inherit nixpkgs-next; };
    sharedModules = [
      { home.stateVersion = "25.11"; }
      ../shells
    ];
  };

  home-manager.users.root = {
    programs.home-manager.enable = true;

    programs.starship.settings.character = lib.modules.mkForce {
      success_symbol = "[#](bold yellow)";
      error_symbol = "[#](bold red bg:white)";
    };
  };
}
