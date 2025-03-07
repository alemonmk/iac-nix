final: prev: {
  squid = prev.squid.override {
    ipv6 = false;
  };

  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: rec {
    version = "dns-server-v13.4";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "TechnitiumLibrary";
      tag = version;
      hash = "sha256-mNWEQAN7T29GmX3mGPrJ5GhELUYNJTvUAhyEWZwN5Vw=";
      name = "${old.pname}-${version}";
    };
  });

  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: rec {
    version = "13.4";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "DnsServer";
      tag = "v${version}";
      hash = "sha256-ikq+0n/VqSxG2Hnn802EkHFpmsn25expBQnTJ69gktk=";
      name = "${old.pname}-${version}";
    };
    patches = [
      ../blobs/technitium-dns-server/webReqProxy.patch
    ];
  });

  code-server = final.callPackage ../pkgs/code-server.nix {};
}
