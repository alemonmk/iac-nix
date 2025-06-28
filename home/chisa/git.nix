{
  programs.git = {
    enable = true;
    userName = "Lemon Lam";
    userEmail = "alemonmk@users.noreply.github.com";
    ignores = [ ".DS_Store" ];
    extraConfig = {
      init.defaultBranch = "main";
      diff.submodule = "log";
      submodule.recurse = true;
      status.submodulesummary = true;
      push.autoSetupRemote = true;
      push.recurseSubmodules = "on-demand";
    };
  };
}
