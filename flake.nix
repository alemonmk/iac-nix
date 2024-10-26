{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/32e940c7c420600ef0d1ef396dc63b04ee9cad37";
    nixpkgs-next.url = "github:nixos/nixpkgs/41dea55321e5a999b17033296ac05fe8a8b5a257";
    impermanence.url = "github:nix-community/impermanence/e337457502571b23e449bf42153d7faa10c0a562";
    sops-nix.url = "github:Mic92/sops-nix/78a0e634fc8981d6b564f08b6715c69a755c4c7d";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    disko.url = "github:nix-community/disko/09a776702b004fdf9c41a024e1299d575ee18a7d";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # unattended-installer.url = "github:chrillefkr/nixos-unattended-installer";
    # unattended-installer.inputs.disko.follows = "disko";
    # unattended-installer.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/7840909b00fbd5a183008a6eb251ea307fe4a76e";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-next";
    home-manager.url = "github:nix-community/home-manager/93435d27d250fa986bfec6b2ff263161ff8288cb";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-next";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-next,
    impermanence,
    sops-nix,
    disko,
    # unattended-installer,
    nix-darwin,
    home-manager,
    ...
  } @ inputs: {
    lib = import ./lib inputs;
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    formatter.x86_64-darwin = nixpkgs-next.legacyPackages.x86_64-darwin.alejandra;
    devShells.x86_64-linux.default = import ./devshell.nix {
      inherit nixpkgs;
      system = "x86_64-linux";
    };
    devShells.x86_64-darwin.default = import ./devshell.nix {
      inherit nixpkgs;
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
