{
  ffmpeg_7-headless,
  fetchFromGitHub,
  fetchpatch,
  lib,
}: let
  version = "7.0.2-5";
in
  (ffmpeg_7-headless.override {
    inherit version;
    source = fetchFromGitHub {
      owner = "jellyfin";
      repo = "jellyfin-ffmpeg";
      rev = "v${version}";
      hash = "sha256-cqyXQNx65eLEumOoSCucNpAqShMhiPqzsKc/GjKKQOA=";
    };
    withUnfree = true;
    withAlsa = false;
    withAmf = false;
    withCelt = false;
    withFdkAac = true;
    withFontconfig = false;
    withFreetype = false;
    withHarfbuzz = false;
    withNvcodec = false;
    withRist = false;
    withSpeex = false;
    withSrt = false;
    withSsh = false;
    withTheora = false;
    withVaapi = false;
    withRuntimeCPUDetection = false;
    withHtmlDoc = false;
    withManPages = false;
    withPodDoc = false;
    withTxtDoc = false;
  })
  .overrideAttrs (old: {
    pname = "jellyfin-ffmpeg";

    configureFlags =
      old.configureFlags
      ++ [
        "--extra-version=Jellyfin"
        "--disable-ptx-compression"
      ];

    postPatch = ''
      for file in $(cat debian/patches/series); do
        patch -p1 < debian/patches/$file
      done

      ${old.postPatch or ""}
    '';

    meta = {
      inherit (old.meta) license mainProgram;
      changelog = "https://github.com/jellyfin/jellyfin-ffmpeg/releases/tag/v${version}";
      description = "${old.meta.description} (Jellyfin fork)";
      homepage = "https://github.com/jellyfin/jellyfin-ffmpeg";
      maintainers = with lib.maintainers; [justinas];
      pkgConfigModules = ["libavutil"];
    };
  })
