final: prev: {
  seaweedfs = prev.seaweedfs.overrideAttrs {
    version = "4.27";
    src = prev.pkgs.fetchFromGitHub {
      owner = "seaweedfs";
      repo = "seaweedfs";
      tag = "4.27";
      leaveDotGit = true;
      postFetch = prev.seaweedfs.src.postFetch;
      hash = "sha256-0z1v7bzPPnUYsjAiIqofkYN29t+0IdO9caPqD+VgR5c=";
    };
    vendorHash = "sha256-6/0d7rmZZahRJ9tlrOR84/B+u1311bWjvPKz/sZ86Dc=";
    doCheck = false;
    doInstallCheck = false;
  };
}
