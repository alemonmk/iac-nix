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

  linuxPackageFrom = f: nixpkgs.legacyPackages."${linuxSystem}".callPackage f { };
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
    (
      n:
      f [
        { networking.hostName = n; }
        (base + /${n}/configuration.nix)
      ]
    )
    |> (genAttrs <| (base |> listFolders));
  forNixFilesAsModules =
    base:
    base
    |> listNixFiles
    |> filter (x: x != "default.nix")
    |> map (x: removeSuffix ".nix" x)
    |> (x: genAttrs x (n: base + /${n}.nix));
  forNixFilesAsSystems =
    f: base:
    (
      n:
      f [
        { networking.hostName = n; }
        (base + /${n}.nix)
      ]
    )
    |> (genAttrs <| (base |> listNixFiles |> map (x: x |> removeSuffix ".nix")));

  mkLinuxPackageSet = set: ((_: v: v |> linuxPackageFrom) |> mapAttrs) <| set;
}
