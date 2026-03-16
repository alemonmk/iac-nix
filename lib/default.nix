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
}@inputs:
let
  inherit (nixpkgs.lib.lists) map filter flatten;
  inherit (nixpkgs.lib.attrsets)
    attrNames
    attrValues
    genAttrs
    mapAttrs
    filterAttrs
    ;
  inherit (nixpkgs.lib.strings) hasSuffix removeSuffix;
  inherit (builtins) readDir;

  linuxSystem = "x86_64-linux";
  darwinSystem = "x86_64-darwin";
  flakeRoot = ../.;

  mkConfigFor = system: modules: {
    specialArgs = {
      inherit self flakeRoot;
      nixpkgs-next = import nixpkgs-next {
        localSystem = system;
        overlays = [ (import ../overlays/next.nix) ];
        config.allowUnfree = true;
      };
    };
    modules = [ { nixpkgs.hostPlatform = system; } ] ++ modules;
  };
  newLinuxSystem = modules: modules |> mkConfigFor linuxSystem |> nixpkgs.lib.nixosSystem;
  newDarwinSystem = modules: modules |> mkConfigFor darwinSystem |> nix-darwin.lib.darwinSystem;

  modulesInhouse = [
    (attrValues self.nixosModules)
    impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    ../base/inhouse/configuration.nix
    ../home/nixos
  ];
  modulesLinodes = [
    self.nixosModules.vpn-route-gen
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    ../base/linode/configuration.nix
    ../home/nixos
  ];
  modulesDarwin = [
    home-manager-darwin.darwinModules.home-manager
    ../home/darwin
  ];

  listFolders = base: base |> readDir |> filterAttrs (_: v: v == "directory") |> attrNames;
  listFiles = base: base |> readDir |> filterAttrs (_: v: v == "regular") |> attrNames;
  listNixFiles = base: base |> listFiles |> filter (s: hasSuffix ".nix" s);

  linuxPackageFrom = def: (def |> nixpkgs.legacyPackages."${linuxSystem}".callPackage) <| { };
in
{
  inherit newLinuxSystem newDarwinSystem;

  stage1System =
    [
      disko.nixosModules.disko
      ../barebone/diskolayout.nix
      ../barebone/configuration.nix
    ]
    |> newLinuxSystem;
  stage1LinodeSystem =
    [
      ../barebone/linode/configuration.nix
    ]
    |> newLinuxSystem;
  finalSystem =
    sysDef:
    [
      modulesInhouse
      sysDef
    ]
    |> flatten
    |> newLinuxSystem;
  finalLinodeSystem =
    sysDef:
    [
      modulesLinodes
      sysDef
    ]
    |> flatten
    |> newLinuxSystem;
  finalDarwinSystem =
    sysDef:
    [
      modulesDarwin
      sysDef
    ]
    |> flatten
    |> newDarwinSystem;

  forFoldersAsSystems =
    f: base:
    base
    |> listFolders
    |> (
      x:
      genAttrs x (
        n:
        f [
          { networking.hostName = n; }
          (base + /${n}/configuration.nix)
        ]
      )
    );
  forNixFilesAsModules =
    base:
    base
    |> listNixFiles
    |> filter (x: x != "default.nix")
    |> map (x: removeSuffix ".nix" x)
    |> (x: genAttrs x (n: base + /${n}.nix));
  forNixFilesAsSystems =
    f: base:
    base
    |> listNixFiles
    |> map (x: x |> removeSuffix ".nix")
    |> (
      x:
      genAttrs x (
        n:
        f [
          { networking.hostName = n; }
          (base + /${n}.nix)
        ]
      )
    );

  mkLinuxPackageSet = set: set |> mapAttrs (_: v: linuxPackageFrom v);
  importAndInit = n: import n inputs;
}
