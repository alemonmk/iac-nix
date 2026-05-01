final: prev: {
  seaweedfs = prev.seaweedfs.overrideAttrs {
    version = "4.22-unstable-20260429";
    src = prev.pkgs.fetchFromGitHub {
      owner = "seaweedfs";
      repo = "seaweedfs";
      rev = "e82789ea4bf7a19eb6f40a93d795a12b3e9567ff";
      leaveDotGit = true;
      postFetch = ''
        pushd "$out"
        git rev-parse --short HEAD 2>/dev/null >$out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
        popd
      '';
      hash = "sha256-0j1MGxQZY63QGkonsGwMkRF5DH1mWOhN3Xc5lci6vXM=";
    };
    vendorHash = "sha256-tV8MbNWIApvCl6Q+c7kDDuz+04rIkcbeL7Z2jJ7gf/8=";
    doCheck = false;
    doInstallCheck = false;
  };
}
