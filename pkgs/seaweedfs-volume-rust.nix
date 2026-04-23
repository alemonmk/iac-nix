{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-volume-rust";
  version = "4.21";

  src = fetchFromGitHub {
    owner = "seaweedfs";
    repo = "seaweedfs";
    tag = finalAttrs.version;
    hash = "sha256-toOPtQeqoluHZoUd/r0ZT8C/SdPPT7KKgU8Jd/XH5hA=";
  };
  sourceRoot = "${finalAttrs.src.name}/seaweed-volume";

  cargoHash = "sha256-Vj6krBkyCHjC+iyKtsi7QXrHwR8Hk7nNtfkjq9kHf8w=";

  nativeBuildInputs = [ protobuf ];

  meta = {
    description = "The Rust volume server (weed-volume) is a drop-in replacement for the Go SeaweedFS volume server";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "weed-volume";
  };
})
