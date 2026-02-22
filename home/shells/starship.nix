{ nixpkgs-next, ... }:
{
  programs.starship = {
    enable = true;
    package = nixpkgs-next.starship;
    enableNushellIntegration = true;
    settings = {
      format = "$username$hostname $directory$python$character";
      right_format = "$git_status$git_branch$git_state";
      continuation_prompt = "[>>>](bright-black) ";
      add_newline = true;
      directory = {
        fish_style_pwd_dir_length = 1;
        read_only = "[RO]";
      };
      character = {
        success_symbol = "[%](bold yellow)";
        error_symbol = "[%](bold red bg:white)";
      };
      hostname = {
        ssh_only = false;
        ssh_symbol = "";
        style = "dimmed green";
        format = "@[$hostname]($style)";
      };
      username = {
        show_always = true;
        style_user = "white";
        format = "[$user]($style)";
      };
      python = {
        symbol = "Py ";
        style = "bold green";
        format = "w/ [$symbol($version )(\($virtualenv\) )]($style)";
      };
    };
  };
}
