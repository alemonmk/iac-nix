{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-next.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-linux.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager-linux.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs?ref=nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin?ref=nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-next,
    impermanence,
    sops-nix,
    disko,
    home-manager-linux,
    nixpkgs-darwin,
    nix-darwin,
    home-manager-darwin,
    ...
  } @ inputs: {
    lib = import ./lib inputs;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs-darwin.legacyPackages.x86_64-darwin.alejandra;
    nixosModules = import ./modules/nixos;
    stage1InstallerModules = import ./modules/installer;
    nixosConfigurations = with self.lib; {
      netbootImage = stage1Installer;
      barebone = stage1System;
      rmnmvatpki = finalSystem [./nodes/atpki.nix];
      rmnmvntpsrv01 = finalSystem [./nodes/ntpsrv01.nix];
      rmnmvnfdns01 = finalSystem [./nodes/nfdns01.nix];
      rmnmvnfdns02 = finalSystem [./nodes/nfdns02.nix];
      rmnmvytarc = finalSystem [./nodes/ytarc.nix];
      rmnmvnocmt01 = finalSystem [./nodes/nocmt01.nix];
      rmnmvmgnix = finalSystem [./nodes/mgnix.nix];
      rmnmvvpngw = finalSystem [./nodes/vpngw.nix];
      rmnmvwebgw = finalSystem [./nodes/webgw.nix];
      rmnmvadb02 = finalSystem [./nodes/adb02.nix];
    };
    darwinConfigurations = with self.lib; {
      chisa = finalDarwinSystem [./nodes/chisa.nix];
    };
  };
}
