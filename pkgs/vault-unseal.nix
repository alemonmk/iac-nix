{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "vault-unseal";
  version = "1.0.1";
  src = fetchFromGitHub {
    owner = "lrstanley";
    repo = "vault-unseal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9cPFzo1L1rc+QMW6rFZYaFQVN3vuqUK1ezrHKa/qjio=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      git log -1 --format=%cd --date=iso-strict > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -exec rm -rf '{}' '+'
    '';
  };
  vendorHash = "sha256-/ov2rvVZJgRsALgBMTaQE4CXplBJDhBrlIq2rHblO4k=";

  ldflags = [
    "-s"
    "-extldflags=-static"
    "-X main.version=${finalAttrs.version}"
  ];
  preBuild = ''
    ldflags+=" -X main.commit=$(cat COMMIT)"
    ldflags+=" -X main.date=$(cat SOURCE_DATE_EPOCH)"
  '';
  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];

  meta = {
    changelog = "https://github.com/lrstanley/vault-unseal/releases/tag/v${finalAttrs.version}";
    description = "Auto-unseal utility for Hashicorp Vault";
    homepage = "https://github.com/lrstanley/vault-unseal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "vault-unseal";
  };
})
