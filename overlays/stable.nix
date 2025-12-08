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

  squid = prev.squid.override { ipv6 = false; };

  code-server = final.callPackage ../pkgs/code-server.nix { };

  vlmcsd = final.callPackage ../pkgs/vlmcsd.nix { };

  vpn-route-gen = final.callPackage ../pkgs/vpn-route-gen/package.nix { };

  zerotierone = prev.zerotierone.override { enableUnfree = true; };
}
