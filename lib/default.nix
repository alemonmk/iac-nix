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

  constructSystem = system: modules: {
    specialArgs = {
      inherit self flakeRoot;
      nixpkgs-next = import nixpkgs-next {
        inherit system;
        overlays = [ (import ../overlays/next.nix) ];
        config.allowUnfree = true;
      };
    };
    inherit modules;
  };
  newLinuxSystem = modules: nixpkgs.lib.nixosSystem (constructSystem linuxSystem modules);
  newDarwinSystem = modules: nix-darwin.lib.darwinSystem (constructSystem darwinSystem modules);

  modulesInhouse = nixpkgs.lib.lists.flatten [
    (nixpkgs.lib.attrsets.attrValues self.nixosModules)
    impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    ../base/inhouse/configuration.nix
  ];
  modulesLinodes = [
    self.nixosModules.vpn-route-gen
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    ../base/linode/configuration.nix
  ];
  modulesDarwin = [ home-manager-darwin.darwinModules.home-manager ];
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
  finalSystem = sysDef: newLinuxSystem (modulesInhouse ++ sysDef);
  finalLinodeSystem = sysDef: newLinuxSystem (modulesLinodes ++ sysDef);
  finalDarwinSystem = sysDef: newDarwinSystem (modulesDarwin ++ sysDef);
  linuxPackageFrom = f: nixpkgs.legacyPackages."${linuxSystem}".callPackage f { };
}
