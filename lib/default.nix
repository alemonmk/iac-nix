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
  inherit (nixpkgs.lib.lists)
    elem
    map
    filter
    flatten
    ;
  inherit (nixpkgs.lib.attrsets)
    attrNames
    attrValues
    mapAttrs
    filterAttrs
    ;
  inherit (nixpkgs.lib.strings) hasPrefix hasSuffix removeSuffix;
  inherit (builtins) readDir;
  genAttrs = generator: list: nixpkgs.lib.attrsets.genAttrs list generator;

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

  forNixFilesAsModules =
    let
      notHasPrefix = p: v: !hasPrefix p v;
    in
    base:
    base
    |> listNixFiles
    |> filter (notHasPrefix "default")
    |> map (removeSuffix ".nix")
    |> genAttrs (n: base + /${n}.nix);
  forNixFilesAsModules' = base: base |> self.lib.forNixFilesAsModules |> attrValues;

  modulesInhouse = [
    (self.nixosModules |> attrValues)
    impermanence.nixosModules.impermanence
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    (../systems/commons |> self.lib.forNixFilesAsModules')
    ../home/nixos
  ];
  modulesLinodes = [
    sops-nix.nixosModules.sops
    home-manager-linux.nixosModules.home-manager
    (../systems/commons |> self.lib.forNixFilesAsModules')
    (../systems/linode |> self.lib.forNixFilesAsModules')
    ../home/nixos
  ];
  modulesDarwin = [
    home-manager-darwin.darwinModules.home-manager
    ../home/darwin
  ];

  listFolders = base: base |> readDir |> filterAttrs (_: v: v == "directory") |> attrNames;
  listFiles = base: base |> readDir |> filterAttrs (_: v: v == "regular") |> attrNames;
  listNixFiles = base: base |> listFiles |> filter (hasSuffix ".nix");

  linuxPackageFrom = def: nixpkgs.legacyPackages."${linuxSystem}".callPackage def { };
  linuxPackagesFrom = def: nixpkgs.legacyPackages."${linuxSystem}".callPackages def { };
in
{
  inherit genAttrs;
  importAndInit = n: import n inputs;

  inherit linuxPackageFrom linuxPackagesFrom;
  mkLinuxPackageSet = set: set |> mapAttrs (_: v: linuxPackageFrom v);

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

  inherit forNixFilesAsModules forNixFilesAsModules';

  forFoldersAsSystems =
    let
      sysDef = base: host: [
        { networking.hostName = host; }
        (base + /base |> self.lib.forNixFilesAsModules')
        (base + /${host} |> self.lib.forNixFilesAsModules')
      ];
      ignores = [ "base" ];
    in
    builder: base:
    base
    |> listFolders
    |> filter (n: !elem n ignores)
    |> genAttrs (host: host |> sysDef base |> builder);
}
