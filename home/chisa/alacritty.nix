{
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    settings = {
      general = {
        live_config_reload = true;
      };
      colors = {
        primary = {
          background = "#ffffff";
          foreground = "#4d4d4c";
        };
        normal = {
          black = "#ffffff";
          blue = "#4271ae";
          cyan = "#3e999f";
          green = "#718c00";
          magenta = "#8959a8";
          red = "#c82829";
          white = "#4d4d4c";
          yellow = "#eab700";
        };
        bright = {
          black = "#8e908c";
          blue = "#4271ae";
          cyan = "#3e999f";
          green = "#718c00";
          magenta = "#8959a8";
          red = "#c82829";
          white = "#1d1f21";
          yellow = "#eab700";
        };
        indexed_colors = [
          {
            index = 16;
            color = "#f5871f";
          }
          {
            index = 17;
            color = "#a3685a";
          }
          {
            index = 18;
            color = "#e0e0e0";
          }
          {
            index = 19;
            color = "#d6d6d6";
          }
          {
            index = 20;
            color = "#969896";
          }
          {
            index = 21;
            color = "#282a2e";
          }
        ];
      };
      cursor = {
        blink_interval = 500;
        style = {
          blinking = "Always";
        };
      };
      font = {
        size = 12.0;
        normal = {
          family = "Menlo";
        };
        offset = {
          x = 1;
          y = 2;
        };
      };
      mouse = {
        hide_when_typing = true;
      };
      selection = {
        save_to_clipboard = true;
      };
      window = {
        decorations = "Full";
        dynamic_title = true;
        opacity = 0.8;
        option_as_alt = "Both";
        padding = {
          x = 6;
          y = 6;
        };
      };
    };
  };
}
