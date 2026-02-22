final: prev: {
  jellyfin-ffmpeg = prev.jellyfin-ffmpeg.override {
    ffmpeg_7-full = prev.ffmpeg_7-headless.override {
      withUnfree = true;
      withAlsa = false;
      withAmf = false;
      withBluray = false;
      withCudaLLVM = false;
      withDrm = false;
      withFdkAac = true;
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
      withZvbi = false;
      withRuntimeCPUDetection = false;
      withDoc = false;
      withManPages = false;
    };
  };

  squid = prev.squid.override { ipv6 = false; };

  zerotierone = prev.zerotierone.override { enableUnfree = true; };
}
