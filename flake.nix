{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-next.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-next";
    disko.url = "github:nix-community/disko?ref=v1.12.0";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-linux.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager-linux.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-darwin.url = "github:nixos/nixpkgs?ref=nixpkgs-25.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin?ref=nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    home-manager-darwin.url = "github:nix-community/home-manager?ref=release-25.11";
    home-manager-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs-next";
  };

  outputs =
    inputs:
    let
      lib = import ./lib inputs;
      nixosModules = lib.forNixFilesAsModules ./modules/nixos;
      sysDefs = import ./systems inputs;
      ciDefs = import ./ci inputs;
      formatter = import ./treefmt.nix inputs;
      barebone = lib.stage1System;
      linodeBarebone = lib.stage1LinodeSystem;
    in
    {
      inherit lib formatter nixosModules;
      packages.x86_64-linux =
        lib.mkLinuxPackageSet {
          code-server = ./pkgs/code-server.nix;
          vlmcsd = ./pkgs/vlmcsd.nix;
          vpn-route-gen = ./pkgs/vpn-route-gen/package.nix;
        }
        // {
          netbootImage = import ./lib/stage1installer inputs;
        };
      nixosConfigurations = sysDefs.nixos // {
        inherit barebone linodeBarebone;
      };
      darwinConfigurations = sysDefs.darwin;
      hydraJobs = ciDefs;
    };
}
