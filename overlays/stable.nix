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

  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: rec {
    patches = [ ../blobs/technitium-dns-server/webReqProxy.patch ];
  });

  code-server = final.callPackage ../pkgs/code-server.nix { };

  vlmcsd = final.callPackage ../pkgs/vlmcsd.nix { };

  vpn-route-gen = final.callPackage ../pkgs/vpn-route-gen/package.nix { };

  zerotierone = final.callPackage ../pkgs/zerotierone/package.nix { enableUnfree = true; };
}
