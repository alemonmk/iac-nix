{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
  seaweedfs,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-volume-rust";
  version = seaweedfs.version;

  src = seaweedfs.src;
  sourceRoot = "${finalAttrs.src.name}/seaweed-volume";

  cargoHash = "sha256-lWwoUHgbcg/rZyNYNS5NyNqA8pjsixhCtsUJhkTk+cA=";

  env.PROTOC = lib.getExe protobuf;

  nativeBuildInputs = [ protobuf ];

  meta = {
    description = "The Rust volume server (weed-volume) is a drop-in replacement for the Go SeaweedFS volume server";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "weed-volume";
  };
})
