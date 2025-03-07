final: prev: {
  squid = prev.squid.override {
    ipv6 = false;
  };

  technitium-dns-server-library = prev.technitium-dns-server-library.overrideAttrs (old: rec {
    version = "dns-server-v13.4.2";
    versionForDotnet = "13.4.2";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "TechnitiumLibrary";
      tag = version;
      hash = "sha256-46RoUxfMMVqh5DQjY3Q8JpIE1afljduHvbBgL1n7suA=";
      name = "${old.pname}-${version}";
    };
  });

  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: rec {
    version = "13.4.3";
    versionForDotnet = "13.4.3";
    src = prev.fetchFromGitHub {
      owner = "TechnitiumSoftware";
      repo = "DnsServer";
      tag = "v${version}";
      hash = "sha256-4RPJS/mxGCre6BYI75z71QPxx+ExOKy0r/Vr2dxLPWY=";
      name = "${old.pname}-${version}";
    };
    patches = [
      ../blobs/technitium-dns-server/webReqProxy.patch
    ];
  });

  code-server = final.callPackage ../pkgs/code-server.nix {};
}
