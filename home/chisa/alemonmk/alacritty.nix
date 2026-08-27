{
  programs.alacritty = {
    enable = true;
    theme = "catppuccin_latte";
    settings = {
      general.live_config_reload = true;
      cursor = {
        blink_interval = 500;
        style.blinking = "Always";
      };
      mouse.hide_when_typing = true;
      selection.save_to_clipboard = true;
      terminal.shell = {
        program = "/run/current-system/sw/bin/nu";
        args = [ "-l" ];
      };
      window = {
        decorations = "Full";
        dynamic_title = true;
        option_as_alt = "Both";
        padding.x = 6;
        padding.y = 6;
      };
      font = {
        size = 12.0;
        normal.family = "Input Mono";
        offset.x = 1;
        offset.y = 2;
      };
    };
  };
}
