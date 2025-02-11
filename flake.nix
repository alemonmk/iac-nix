{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-next.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs?ref=nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin?ref=nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager.url = "github:nix-community/home-manager?ref=release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-next";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-next,
    impermanence,
    sops-nix,
    disko,
    nixpkgs-darwin,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: {
    lib = import ./lib inputs;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs-darwin.legacyPackages.x86_64-darwin.alejandra;
    devShells.x86_64-linux.default = import ./devshell.nix {
      inherit nixpkgs;
      system = "x86_64-linux";
    };
    devShells.x86_64-darwin.default = import ./devshell.nix {
      nixpkgs = nixpkgs-darwin;
      system = "x86_64-darwin";
    };
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
    };
    darwinConfigurations = {
      chisa = nix-darwin.lib.darwinSystem {
        modules = [
          ./nodes/chisa.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manager.users.alemonmk = import ./home/chisa;
          }
        ];
      };
    };
  };
}
