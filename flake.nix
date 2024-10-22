{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/89172919243df199fe237ba0f776c3e3e3d72367";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/1997e4aa514312c1af7e2bda7fad1644e778ff26";
    impermanence.url = "github:nix-community/impermanence/e337457502571b23e449bf42153d7faa10c0a562";
    sops-nix.url = "github:Mic92/sops-nix/26642e8f193f547e72d38cd4c0c4e45b49236d27";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sops-nix.inputs.nixpkgs-stable.follows = "nixpkgs";
    disko.url = "github:nix-community/disko/4be2aadf13b67ffbb993deb73adff77c46b728fc";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # unattended-installer.url = "github:chrillefkr/nixos-unattended-installer";
    # unattended-installer.inputs.disko.follows = "disko";
    # unattended-installer.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin/64d9d1ae25215c274c37e3e4016977a6779cf0d3";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/5ec753a1fc4454df9285d8b3ec0809234defb975";
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
      rmnmvntpsrv01 = finalSystem [./nodes/ntpsrv01.nix];
      rmnmvnfdns01 = finalSystem [./nodes/nfdns01.nix];
      rmnmvnfdns02 = finalSystem [./nodes/nfdns02.nix];
    };
  };
}
