{
  description = "Hydra CI - NixOS configurations";

  inputs.iac-nix.url = "git+https://code.rmntn.net/iac/nix?ref=main&shallow=1";

  outputs = {iac-nix, ...}: {
    hydraJobs.hosts = builtins.mapAttrs (_: cfg: cfg.config.system.build.toplevel) iac-nix.nixosConfigurations;
  };
}
