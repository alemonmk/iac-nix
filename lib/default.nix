{
  self,
  nixpkgs,
  nixpkgs-next,
  nix-darwin,
  impermanence,
  sops-nix,
  disko,
  home-manager-linux,
  home-manager-darwin,
  ...
}: let
  linuxSystem = "x86_64-linux";
  darwinSystem = "x86_64-darwin";
in {
  stage1System = nixpkgs.lib.nixosSystem {
    modules = [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ../barebone/configuration.nix
    ];
  };
  stage1LinodeSystem = nixpkgs.lib.nixosSystem {
    modules = [../barebone/linode/configuration.nix];
  };
  finalSystem = sysDef:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        nixpkgs-next = import nixpkgs-next {
          system = linuxSystem;
          overlays = [(import ../overlays/next.nix)];
          config.allowUnfree = true;
        };
      };
      modules =
        [
          self.nixosModules
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager-linux.nixosModules.home-manager
          ../base/inhouse/configuration.nix
        ]
        ++ sysDef;
    };
  finalLinodeSystem = sysDef:
    nixpkgs.lib.nixosSystem {
      modules =
        [
          sops-nix.nixosModules.sops
          ../base/linode/configuration.nix
        ]
        ++ sysDef;
    };
  finalDarwinSystem = sysDef:
    nix-darwin.lib.darwinSystem {
      specialArgs = {
        nixpkgs-next = import nixpkgs-next {
          system = darwinSystem;
          config.allowUnfree = true;
        };
      };
      modules = [home-manager-darwin.darwinModules.home-manager] ++ sysDef;
    };
}
