{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # unattended-installer.url = "github:chrillefkr/nixos-unattended-installer";
    # unattended-installer.inputs.disko.follows = "disko";
    # unattended-installer.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
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
    formatter.x86_64-darwin = nixpkgs-unstable.legacyPackages.x86_64-darwin.alejandra;
    devShells.x86_64-linux.default = import ./devshell.nix {
      inherit nixpkgs;
      system = "x86_64-linux";
    };
    devShells.x86_64-darwin.default = import ./devshell.nix {
      inherit nixpkgs;
      system = "x86_64-darwin";
    };
    nixosModules = import ./modules/nixos;
    nixosConfigurations = with self.lib; {
      netbootImage = stage1Installer;
      barebone = stage1System;
    };
  };
}
