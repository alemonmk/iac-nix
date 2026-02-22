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
}:
let
  linuxSystem = "x86_64-linux";
  darwinSystem = "x86_64-darwin";
  flakeRoot = ./..;
in
{
  stage1System = nixpkgs.lib.nixosSystem {
    modules = [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ../barebone/configuration.nix
    ];
  };
  stage1LinodeSystem = nixpkgs.lib.nixosSystem {
    modules = [ ../barebone/linode/configuration.nix ];
  };
  finalSystem =
    sysDef:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit flakeRoot;
        nixpkgs-next = import nixpkgs-next {
          system = linuxSystem;
          overlays = [ (import ../overlays/next.nix) ];
          config.allowUnfree = true;
        };
      };
      modules =
        nixpkgs.lib.attrValues self.nixosModules
        ++ [
          impermanence.nixosModules.impermanence
          sops-nix.nixosModules.sops
          home-manager-linux.nixosModules.home-manager
          ../base/inhouse/configuration.nix
        ]
        ++ sysDef;
    };
  finalLinodeSystem =
    sysDef:
    nixpkgs.lib.nixosSystem {
      specialArgs = { inherit flakeRoot; };
      modules = [
        self.nixosModules.vpn-route-gen
        sops-nix.nixosModules.sops
        home-manager-linux.nixosModules.home-manager
        ../base/linode/configuration.nix
      ]
      ++ sysDef;
    };
  finalDarwinSystem =
    sysDef:
    nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit flakeRoot;
        nixpkgs-next = import nixpkgs-next {
          system = darwinSystem;
          config.allowUnfree = true;
        };
      };
      modules = [ home-manager-darwin.darwinModules.home-manager ] ++ sysDef;
    };
}
