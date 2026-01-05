{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vlmcsd";
  version = "1113";

  src = fetchFromGitHub {
    owner = "Wind4";
    repo = "vlmcsd";
    tag = "svn${finalAttrs.version}";
    hash = "sha256-OKysOm44T9wrAaopp9HfLlox5InlpV33AHGXRSjhDqc=";
  };

  makefile = "GNUmakefile";

  dontConfigure = true;
  doCheck = false;

  buildFlags = [
    "AR=gcc-ar"
    "THREADS=1"
    "CRYPTO=internal"
  ];
  preBuild = ''
    buildFlagsArray+=(VLMCSD_VERSION="${finalAttrs.version}")
    buildFlagsArray+=(PLATFORMFLAGS="-fwhole-program -m64 -mtune=generic")
    buildFlagsArray+=(CFLAGS="-DNO_RANDOM_EPID -DNO_PID_FILE -DNO_USER_SWITCH -DNO_CUSTOM_INTERVALS \
    -DNO_FREEBIND -DNO_CL_PIDS -DNO_PRIVATE_IP_DETECT")
    buildFlagsArray+=(LDFLAGS="-Wl,--build-id=none -Wl,--hash-style=gnu")
  '';

  installPhase = ''
    runHook preInstall
    install -Dm555 bin/* -t $out/bin
    runHook postInstall
  '';

  meta = {
    description = "Portable open-source KMS Emulator in C";
    homepage = "https://github.com/Wind4/vlmcsd";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ alemonmk ];
    platforms = lib.platforms.linux;
  };
})
