{
  programs.alacritty = {
    enable = true;
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
        opacity = 0.8;
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
      colors = {
        primary = {
          background = "#eff1f5";
          foreground = "#4c4f69";
          dim_foreground = "#8c8fa1";
          bright_foreground = "#4c4f69";
        };
        normal = {
          black = "#bcc0cc";
          red = "#d20f39";
          green = "#40a02b";
          yellow = "#df8e1d";
          blue = "#1e66f5";
          magenta = "#ea76cb";
          cyan = "#179299";
          white = "#5c5f77";
        };
        bright = {
          black = "#acb0be";
          red = "#d20f39";
          green = "#40a02b";
          yellow = "#df8e1d";
          blue = "#1e66f5";
          magenta = "#ea76cb";
          cyan = "#179299";
          white = "#6c6f85";
        };
        selection = {
          text = "#eff1f5";
          background = "#dc8a78";
        };
        cursor = {
          text = "#eff1f5";
          cursor = "#dc8a78";
        };
        vi_mode_cursor = {
          text = "#eff1f5";
          cursor = "#7287fd";
        };
        search = {
          matches = {
            foreground = "#eff1f5";
            background = "#6c6f85";
          };
          focused_match = {
            foreground = "#eff1f5";
            background = "#40a02b";
          };
        };
        footer_bar = {
          foreground = "#eff1f5";
          background = "#6c6f85";
        };
        hints = {
          start = {
            foreground = "#eff1f5";
            background = "#df8e1d";
          };
          end = {
            foreground = "#eff1f5";
            background = "#6c6f85";
          };
        };
        indexed_colors = [
          {
            index = 16;
            color = "#fe640b";
          }
          {
            index = 17;
            color = "#dc8a78";
          }
        ];
      };
    };
  };
}
