{ config, pkgs, lib, ... }:

{

  # ═══════════════════════════════════════════════════════════
  # Alacritty 终端配置
  # ═══════════════════════════════════════════════════════════
  programs.alacritty = {
    enable = true;

    settings = {
      live_config_reload = true;

      env = {
        TERM = "xterm-256color";
        ZELLIJ_AUTO_ATTACH = "true";
        ZELLIJ_AUTO_EXIT = "true";
      };

      shell = {
        program = "/run/current-system/sw/bin/zellij";
        args = [ "attach" "--index=0" "--create" ];
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
          style = "Regular";
        };

        bold = {
          family = "LXGW WenKai Mono";
          style = "Regular";
        };

        italic = {
          family = "LXGW WenKai Mono";
          style = "Regular";
        };

        bold_italic = {
          family = "LXGW WenKai Mono";
          style = "Regular";
        };

        offset = {
          x = 0;
          y = 1;
        };

        glyph_offset = {
          x = 0;
          y = 1;
        };
      };

      cursor = {
        style = {
          shape = "Beam";
        };
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

      keyboard = {
        bindings = [
          { key = "R"; mods = "Command"; chars = "\f"; modes = [ "~Vi" "~Search" ]; }
          { key = "R"; mods = "Command"; action = "ClearHistory"; modes = [ "~Vi" "~Search" ]; }
          { key = "W"; mods = "Command"; action = "Hide"; }
          { key = "W"; mods = "Command|Shift"; action = "Quit"; }
          { key = "N"; mods = "Command"; action = "SpawnNewInstance"; }
          { key = "T"; mods = "Command"; action = "CreateNewWindow"; }
          { key = "Left"; mods = "Alt"; chars = "\u001Bb"; }
          { key = "Right"; mods = "Alt"; chars = "\u001Bf"; }
          { key = "Left"; mods = "Command"; chars = "\u0001"; }
          { key = "Right"; mods = "Command"; chars = "\u0005"; }
          { key = "Back"; mods = "Command"; chars = "\u0015"; }
          { key = "Back"; mods = "Alt"; chars = "\u001B\u007F"; }
        ];
      };
    };
  };
}