{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
  seaweedfs,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-volume-rust";
  version = "4.27";

  src = fetchFromGitHub {
    owner = "seaweedfs";
    repo = "seaweedfs";
    tag = "4.27";
    leaveDotGit = true;
    postFetch = seaweedfs.src.postFetch;
    hash = "sha256-0z1v7bzPPnUYsjAiIqofkYN29t+0IdO9caPqD+VgR5c=";
  };
  sourceRoot = "${finalAttrs.src.name}/seaweed-volume";

  cargoHash = "sha256-XPsuJdNsMNEUuYXUDBQwFuyCBbF3zHPwuZKIciBP6o0=";

  nativeBuildInputs = [ protobuf ];

  checkFlags = [ "--skip=metrics::tests::test_push_metrics_once" ];

  meta = {
    description = "The Rust volume server (weed-volume) is a drop-in replacement for the Go SeaweedFS volume server";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "weed-volume";
  };
})
