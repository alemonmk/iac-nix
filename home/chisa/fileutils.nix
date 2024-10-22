{
  config,
  pkgs,
  ...
}: {
  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [
      "-al"
      "--level=1"
      "--group-directories-first"
      "--git-repos"
      "--total-size"
    ];
  };

  programs.fd = {
    enable = true;
    hidden = true;
    extraOptions = ["-HIu"];
  };
}
