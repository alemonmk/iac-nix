terraform {
  required_providers {
    hydra = {
      version = "~> 0.1"
      source  = "DeterminateSystems/hydra"
    }
  }
}

provider "hydra" {
  host     = "https://nix-ci.snct.rmntn.net"
  username = "system"
}

resource "hydra_project" "iac-nix" {
  name         = "iac-nix"
  display_name = "RemonNet IaC - NixOS server builds"
  homepage     = "https://code.rmntn.net/iac/nix"
  owner        = "system"
  enabled      = true
  visible      = true
}

resource "hydra_jobset" "nixosConfigurations" {
  project             = hydra_project.iac-nix.name
  name                = "nixosConfigurations"
  type                = "flake"
  flake_uri           = "git+https://code.rmntn.net/iac/nix?dir=ci/nixos&ref=main"
  state               = "enabled"
  visible             = true
  check_interval      = 0
  scheduling_shares   = 30
  keep_evaluations    = 5
  email_notifications = false
}

resource "hydra_jobset" "packages" {
  project             = hydra_project.iac-nix.name
  name                = "packages"
  type                = "flake"
  flake_uri           = "git+https://code.rmntn.net/iac/nix?dir=ci/packages&ref=main"
  state               = "enabled"
  visible             = true
  check_interval      = 0
  scheduling_shares   = 10
  keep_evaluations    = 5
  email_notifications = false
}
