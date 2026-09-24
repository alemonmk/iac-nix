{
  lib,
  fetchFromGitHub,
  rustPlatform,
  protobuf,
  seaweedfs,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "seaweedfs-worker";
  version = seaweedfs.version;

  src = seaweedfs.src;
  sourceRoot = "${finalAttrs.src.name}/seaweed-worker";

  cargoHash = lib.fakeHash;

  env.PROTOC = lib.getExe protobuf;

  nativeBuildInputs = [ protobuf ];

  meta = {
    description = "Cluster maintenance job worker of Seaweedfs, currently only handle Lance maintenance";
    homepage = "https://github.com/seaweedfs/seaweedfs";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alemonmk ];
    mainProgram = "weed-worker";
  };
})
