final: prev: {
  seaweedfs = prev.seaweedfs.overrideAttrs {
    version = "4.23";
    src = prev.pkgs.fetchFromGitHub {
      owner = "seaweedfs";
      repo = "seaweedfs";
      tag = "4.23";
      leaveDotGit = true;
      postFetch = ''
        pushd "$out"
        git rev-parse --short HEAD 2>/dev/null >$out/COMMIT
        find "$out" -name .git -print0 | xargs -0 rm -rf
        popd
      '';
      hash = "sha256-ILDnv4ktIvrmmqXO1QSofWf7HHzfycSMn8FJoBlkZzg=";
    };
    vendorHash = "sha256-s6jGCNUCT3LCSaToPdvJTzCF1EFnY4hX/70OUEszoeY=";
    doCheck = false;
    doInstallCheck = false;
  };
}
