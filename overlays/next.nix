final: prev: {
  squid = prev.squid.override {ipv6 = false;};

  technitium-dns-server = prev.technitium-dns-server.overrideAttrs (old: rec {
    patches = [../blobs/technitium-dns-server/webReqProxy.patch];
  });

  code-server = final.callPackage ../pkgs/code-server.nix {};
}
