final: prev: {
  seaweedfs = prev.seaweedfs.overrideAttrs {
    version = "4.29";
    src = prev.pkgs.fetchFromGitHub {
      owner = "seaweedfs";
      repo = "seaweedfs";
      tag = "4.29";
      leaveDotGit = true;
      postFetch = prev.seaweedfs.src.postFetch;
      hash = "sha256-QvKcWIII31NNTKSINJC3wvQCzCHObBLO2c3r6cs2ges=";
    };
    vendorHash = "sha256-b4qgAdhLWL+J0WgKKHD8rxOd/IDI/xLF+tCXdAQrl1c=";
    doCheck = false;
    doInstallCheck = false;
  };
}
