{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-next.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    disko.url = "github:nix-community/disko?ref=v1.12.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-linux.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager-linux.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs?ref=nixpkgs-25.05-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin?ref=nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager?ref=release-25.05";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    lib = import ./lib inputs;
    nixosModules = import ./modules/nixos inputs;
    sysDefs = import ./systems inputs;
    ciDefs = import ./ci inputs;
    barebone = lib.stage1System;
    linodeBarebone = lib.stage1LinodeSystem;
  in {
    inherit lib nixosModules;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs-darwin.legacyPackages.x86_64-darwin.alejandra;
    packages.x86_64-linux = {
      netbootImage = import ./lib/stage1installer inputs;
      vlmcsd = nixpkgs.legacyPackages.x86_64-linux.callPackage ./pkgs/vlmcsd.nix {};
    };
    nixosConfigurations = {inherit barebone linodeBarebone;} // sysDefs.nixos;
    darwinConfigurations = sysDefs.darwin;
    hydraJobs = ciDefs;
  };
}
