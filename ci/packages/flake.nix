{
  description = "Hydra CI - Private packages";

  inputs.iac-nix.url = "git+https://code.rmntn.net/iac/nix?ref=main&shallow=1";

  outputs = {iac-nix, ...}: let
    inherit (iac-nix.inputs) nixpkgs nixpkgs-next;
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.permittedInsecurePackages = ["squid-7.0.1"];
    };
    pkgs-next = nixpkgs-next.legacyPackages.x86_64-linux;
    stable-overlay-realised = iac-nix.overlays.stable pkgs pkgs;
    next-overlay-realised = iac-nix.overlays.next pkgs-next pkgs-next;
    overlays-combined = nixpkgs.lib.mergeAttrs stable-overlay-realised next-overlay-realised;
  in {
    hydraJobs = {
      pkgs.x86_64-linux = overlays-combined // iac-nix.packages.x86_64-linux;
    };
  };
}
