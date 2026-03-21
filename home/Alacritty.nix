{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      general = {
        live_config_reload = true;
      };

      env = {
        TERM = "xterm-256color";
        ZELLIJ_AUTO_ATTACH = "true";
        ZELLIJ_AUTO_EXIT = "true";
      };

      terminal = {
        shell = {
          program = "${pkgs.zellij}/bin/zellij";
          args = [ "attach" "--create" ];
        };
      };

      colors = {
        draw_bold_text_with_bright_colors = false;

        primary = {
          background = "#15141b";
          foreground = "#edecee";
        };

        normal = {
          black = "#110f18";
          red = "#ff6767";
          green = "#61ffca";
          yellow = "#ffca85";
          blue = "#a277ff";
          magenta = "#a277ff";
          cyan = "#61ffca";
          white = "#edecee";
        };

        bright = {
          black = "#4d4d4d";
          red = "#ff6767";
          green = "#61ffca";
          yellow = "#ffca85";
          blue = "#a277ff";
          magenta = "#a277ff";
          cyan = "#61ffca";
          white = "#edecee";
        };

        cursor = {
          cursor = "#00D1FF";
        };

        selection = {
          background = "#29263c";
          text = "CellForeground";
        };

        search = {
          matches = {
            background = "#ffffff";
            foreground = "#000000";
          };
          focused_match = {
            background = "#00D1FF";
            foreground = "#ffffff";
          };
        };
      };

      font = {
        size = 14.0;

        normal = {
          family = "LXGW WenKai Mono";
        };

        bold = {
          family = "LXGW WenKai Mono";
        };

        italic = {
          family = "LXGW WenKai Mono";
        };

        bold_italic = {
          family = "LXGW WenKai Mono";
        };

        offset = {
          x = 0;
          y = 0;
        };

        glyph_offset = {
          x = 0;
          y = 0;
        };
      };

      cursor = {
        style.shape = "Beam";
      };

      scrolling = {
        history = 100000;
        multiplier = 4;
      };

      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = ",│`|:\"' ()[]{}<>";
      };

      window = {
        opacity = 0.8;
        blur = true;
        dynamic_padding = false;
        
        dimensions = {
          columns = 120;
          lines = 30;
        };

        padding = {
          x = 10;
          y = 10;
        };
      };

      bell = {
        animation = "EaseOutQuad";
        duration = 10;
      };

      keyboard.bindings = [
        { key = "R"; mods = "Super"; chars = "\f"; mode = "~Vi|~Search"; }
        { key = "R"; mods = "Super"; action = "ClearHistory"; mode = "~Vi|~Search"; }
        { key = "W"; mods = "Super"; action = "Hide"; }
        { key = "W"; mods = "Super|Shift"; action = "Quit"; }
        { key = "N"; mods = "Super"; action = "SpawnNewInstance"; }
        { key = "T"; mods = "Super"; action = "CreateNewWindow"; }
        { key = "Left"; mods = "Alt"; chars = "\u001Bb"; }
        { key = "Right"; mods = "Alt"; chars = "\u001Bf"; }
        { key = "Left"; mods = "Super"; chars = "\u0001"; }
        { key = "Right"; mods = "Super"; chars = "\u0005"; }
        { key = "Back"; mods = "Super"; chars = "\u0015"; }
        { key = "Back"; mods = "Alt"; chars = "\u001B\u007F"; }
      ];
    };
  };
}