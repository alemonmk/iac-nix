{ pkgs, nixpkgs-next, ... }:
{
  environment.shells = [
    pkgs.bashInteractive
    nixpkgs-next.nushell
  ];
  users.users.root.shell = nixpkgs-next.nushell;
  users.users.emergency.shell = nixpkgs-next.nushell;
}
