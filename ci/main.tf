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

resource "hydra_jobset" "builds" {
  project             = hydra_project.iac-nix.name
  name                = "builds"
  description         = "Builds all overlaid packages and systems."
  type                = "flake"
  flake_uri           = "git+https://code.rmntn.net/iac/nix&ref=main"
  state               = "enabled"
  visible             = true
  check_interval      = 300
  scheduling_shares   = 100
  keep_evaluations    = 10
  email_notifications = false
}