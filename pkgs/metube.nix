{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  dockerTools,
  python3,
  python313Packages,
  deno,
  ffmpeg-headless,
  curlMinimal,
  cacert,
}:
let
  ffmpeg-headless' = ffmpeg-headless.override {
    withAlsa = false;
    withAmf = false;
    withBluray = false;
    withCudaLLVM = false;
    withDrm = false;
    withGmp = false;
    withNvcodec = false;
    withOpenmpt = false;
    withRist = false;
    withSpeex = false;
    withSrt = false;
    withSsh = false;
    withSvtav1 = false;
    withTheora = false;
    withV4l2 = false;
    withVaapi = false;
    withVidStab = false;
    withVulkan = false;
    withX264 = false;
    withX265 = false;
    withXvid = false;
    withZvbi = false;
    withRuntimeCPUDetection = false;
    withDoc = false;
    withManPages = false;
  };
  curl' = curlMinimal.override {
    c-aresSupport = true;
    brotliSupport = true;
    zstdSupport = true;
    websocketSupport = true;
    opensslSupport = false;
    gnutlsSupport = true;
    scpSupport = false;
    gssSupport = false;
  };
  yt-dlp' = python313Packages.yt-dlp.override {
    ffmpeg-headless = ffmpeg-headless';
    rtmpSupport = false;
  };
  bgutil-ytdlp-pot-provider' = python313Packages.bgutil-ytdlp-pot-provider.override {
    yt-dlp = yt-dlp';
  };
  runtimePython3 = python3.withPackages (
    p: with p; [
      aiohttp
      python-socketio
      mutagen
      curl-cffi
      watchfiles
      bgutil-ytdlp-pot-provider'
      yt-dlp'
    ]
  );
  metubeVersion = "2025.12.26";
  metube =
    let
      metube-src = fetchFromGitHub {
        owner = "alexta69";
        repo = "metube";
        tag = metubeVersion;
        hash = "sha256-x70gns4QxsBwkhlXiUKPD4QOQ0skHuk2KWDXR6guMo8=";
      };
      metube-ui = stdenvNoCC.mkDerivation (finalAttrs: {
        pname = "metube-ui";
        version = metubeVersion;
        src = metube-src;
        sourceRoot = "source/ui";
        nativeBuildInputs = [
          nodejs
          pnpm
          pnpmConfigHook
        ];
        pnpmDeps = pnpm.fetchDeps {
          inherit (finalAttrs)
            pname
            version
            src
            sourceRoot
            ;
          fetcherVersion = 3;
          hash = "sha256-sV83ZjYcsoMo2TOvotcUu2MYnOL00Z1lbH62Z+Ttp0s=";
        };
        buildPhase = "pnpm run build";
        installPhase = "cp -R dist $out";
      });
    in
    stdenvNoCC.mkDerivation {
      pname = "metube";
      version = metubeVersion;
      src = metube-src;
      buildInputs = [ runtimePython3 ];
      buildPhase = ''
        rm -r ui && mkdir -p ./ui
        ln -s "${metube-ui}" ./ui/dist
      '';
      installPhase = ''
        mkdir -p $out/metube
        cp -r app/ $out/metube/app/
        cp -r ui/ $out/metube/ui/
      '';
    };
in
dockerTools.buildLayeredImage {
  name = "metube-pot-plugin";
  tag = metubeVersion;
  contents = [
    runtimePython3
    metube
    cacert
    deno
    curl'
    ffmpeg-headless'
  ];
  config = {
    WorkingDir = "/app";
    User = "1000:1000";
    ExposedPorts = {
      "8081/tcp" = { };
    };
    Env = [
      "BASE_DIR=/metube"
      "DOWNLOAD_DIR=/downloads"
      "STATE_DIR=/downloads/.metube"
      "TEMP_DIR=/downloads"
      "METUBE_VERSION=${metubeVersion}"
    ];
    Volumes = {
      "/downloads" = { };
    };
    Entrypoint = [
      "python3"
      "/metube/app/main.py"
    ];
  };
  extraCommands = ''
    mkdir -m 1777 tmp
    mkdir -p app/.cache && chmod 770 app/.cache
  '';
}
