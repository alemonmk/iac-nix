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
    repo = "vault-unseal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ifCmojhePUwzgrMDen5tfLX6s9FyN1KmmuPJIb/WoxY=";
    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      git log -1 --format=%cd --date=iso-strict > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -exec rm -rf '{}' '+'
    '';
  };
  vendorHash = "sha256-ma3xbnWH87b1X5fdOjigzsj5gEfhbjyTLoIDyp9eY80=";

  ldflags = [
    "-s"
    "-w"
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
