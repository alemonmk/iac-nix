{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-next.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    disko.url = "github:nix-community/disko";
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
    nixpkgs-darwin,
    ...
  } @ inputs: {
    lib = import ./lib inputs;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs-darwin.legacyPackages.x86_64-darwin.alejandra;
    nixosModules = import ./modules/nixos;
    nixosConfigurations = with self.lib; {
      netbootImage = stage1Installer;
      barebone = stage1System;
      linodeBarebone = stage1LinodeSystem;
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
      sumire = finalLinodeSystem [./nodes/sumire.nix];
      uzuki = finalLinodeSystem [./nodes/uzuki.nix];
      sajuna = finalLinodeSystem [./nodes/sajuna.nix];
      kumiko = finalLinodeSystem [./nodes/kumiko.nix];
      sena = finalLinodeSystem [./nodes/sena.nix];
    };
    darwinConfigurations = with self.lib; {
      chisa = finalDarwinSystem [./nodes/chisa.nix];
    };
  };
}
