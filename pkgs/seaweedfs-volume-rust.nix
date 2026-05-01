{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-volume-rust";
  version = "4.22-unstable-20260429";

  src = fetchFromGitHub {
    owner = "seaweedfs";
    repo = "seaweedfs";
    rev = "e82789ea4bf7a19eb6f40a93d795a12b3e9567ff";
    hash = "sha256-0j1MGxQZY63QGkonsGwMkRF5DH1mWOhN3Xc5lci6vXM=";
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
