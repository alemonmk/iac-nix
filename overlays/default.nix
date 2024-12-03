final: prev: {
  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.override {
    ffmpeg_7-full = prev.ffmpeg_7-full.override {
      ffmpegVariant = "headless";
      withAlsa = false;
      withFdkAac = true;
      withOpenmpt = true;
      withRuntimeCPUDetection = false;
      withDoc = false;
      withManPages = false;
    };
  };

  prometheus-chrony-exporter = final.callPackage ../pkgs/prometheus-chrony-exporter.nix {};
}
