final: prev: {
  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.override {
    ffmpeg_6-full = prev.ffmpeg_6-full.override {
      ffmpegVariant = "headless";
      withAlsa = false;
      withAom = true;
      withCelt = true;
      withFdkAac = true;
      withOpenmpt = true;
      withOpenjpeg = true;
      withWebp = true;
    };
  };

  prometheus-chrony-exporter = final.callPackage ../pkgs/prometheus-chrony-exporter.nix {};
}
