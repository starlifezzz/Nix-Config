{
  programs.kitty = {
    enable = true;

    # ─── 字体（已更换）────────────────────────────────────
    font = {
      name = "LXGW WenKai Mono";
      size = 14.0; # ⬆️ 霞鹜文楷笔画较细，建议比等宽字体大 1pt
    };

    theme = "Gruvbox Dark";

    settings = {
      scrollback_lines = 10000;
      window_padding_width = "8 12";
      hide_window_decorations = "titlebar-only";
      confirm_os_window_close = "no";
      remember_window_size = "yes";

      cursor_shape = "beam";
      cursor_blink_interval = 0;

      copy_on_select = "clipboard";
      mouse_hide_wait = 3;

      # ⚠️ 霞鹜文楷是中文手写风格字体，连字特性不同于编程字体
      # 关闭连字避免中文渲染异常；英文代码仍正常显示
      font_features = "-liga -calt";
      disable_ligatures = "always";

      ime_preedit_format = "overlay";

      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      enable_audio_bell = "no";
      visual_bell_duration = "0.1";

      url_style = "curly";
      open_url_with = "default";
      close_on_child_death = "yes";
    };

    keybindings = {
      "ctrl+shift+equal" = "change_font_size all +1.0";
      "ctrl+shift+minus" = "change_font_size all -1.0";
      "ctrl+shift+backspace" = "change_font_size all 0";
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+k" = "clear_terminal scrollback active";
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
    };

    shellIntegration = {
      enable = true;
      mode = "no-cursor";
    };

    environment = {
      "KITTY_ENABLE_WAYLAND" = "1";
    };
  };
}
