{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-volume-rust";
  version = "4.23";

  src = fetchFromGitHub {
    owner = "seaweedfs";
    repo = "seaweedfs";
    tag = finalAttrs.version;
    hash = "sha256-SJ3H4zryH+pAUABIHEPwsiVZE7Adnwo048Jaqn7z6M8=";
  };
  sourceRoot = "${finalAttrs.src.name}/seaweed-volume";

  cargoHash = "sha256-XPsuJdNsMNEUuYXUDBQwFuyCBbF3zHPwuZKIciBP6o0=";

  nativeBuildInputs = [ protobuf ];

  meta = {
    description = "The Rust volume server (weed-volume) is a drop-in replacement for the Go SeaweedFS volume server";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "weed-volume";
  };
})
