{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Lemon Lam";
        email = "alemonmk@users.noreply.github.com";
      };
      init.defaultBranch = "main";
      diff.submodule = "log";
      submodule.recurse = true;
      status.submodulesummary = true;
      push.autoSetupRemote = true;
      push.recurseSubmodules = "on-demand";
    };
    ignores = [ ".DS_Store" ];
  };
}
