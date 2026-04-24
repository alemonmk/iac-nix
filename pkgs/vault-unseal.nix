{
  lib,
  fetchFromGitHub,
  buildGo126Module,
}:
buildGo126Module (finalAttrs: {
  pname = "vault-unseal";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "lrstanley";
    repo = finalAttrs.pname;
    tag = "v${finalAttrs.version}";
    hash = "sha256-czfG7DsA6O2n8BlzEEvNtu0Dg277qBnLAdVUZLo6+8w=";
  };
  vendorHash = "sha256-ma3xbnWH87b1X5fdOjigzsj5gEfhbjyTLoIDyp9eY80=";

  ldflags = [
    "-s"
    "-w"
    "-extldflags=-static"
  ];
  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];
  GOFLAGS = [
    "-buildvcs=false"
    "-installsuffix=netgo"
  ];

  meta = {
    changelog = "https://github.com/lrstanley/vault-unseal/releases/tag/v${finalAttrs.version}";
    description = "Auto-unseal utility for Hashicorp Vault";
    homepage = "hhttps://github.com/lrstanley/vault-unseal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "vault-unseal";
  };
})
