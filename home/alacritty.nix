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
      };

      terminal = {
        shell = {
          program = "${pkgs.zellij}/bin/zellij";
          args = [ ];
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
        # // 文本编辑相关
        { key = "Back"; mods = "Super"; chars = "\u0015"; }  # Ctrl+U 删除整行
        { key = "Back"; mods = "Alt"; chars = "\u001B\u007F"; }  # Alt+Backspace 删除单词
        
        # // 单词导航
        { key = "Left"; mods = "Alt"; chars = "\u001Bb"; }  # Alt+← 跳到前一个单词
        { key = "Right"; mods = "Alt"; chars = "\u001Bf"; }  # Alt+→ 跳到下一个单词
        
        # // Shell 导航快捷键（与 Fish Shell 配合）
        { key = "Left"; mods = "Super"; chars = "\u0001"; }  # Ctrl+A 行首
        { key = "Right"; mods = "Super"; chars = "\u0005"; }  # Ctrl+E 行尾
      ];
    };
  };
}