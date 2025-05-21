final: prev: {
  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.override {
    ffmpeg_7-full = prev.ffmpeg_7-headless.override {
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
    };
  };
  prometheus-chrony-exporter = final.callPackage ../pkgs/prometheus-chrony-exporter.nix {};
}
