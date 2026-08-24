# /etc/nixos/home/zellij.nix
# Zellij Terminal Multiplexer 配置

{
  programs.zellij = {
    enable = true;

    # ═══ 基础配置（结构化，由 HM 生成 KDL，无注释语法风险）═══
    settings = {
      default_shell = "fish";
      theme = "gruvbox-dark";
      show_startup_tips = false;
      session_serialization = false;

      # v0.45.0 UI 适配
      pane_frame_style = "full"; # 删除此行则使用新版单行标题栏
      stacked_pane_list = false; # 删除此行则使用新版列表式 stacked
      nested_session_handling = "ask"; # 嵌套会话策略
      mouse_hover_tips = true; # 按需开启
      mouse_scroll_resize = true; # 按需开启

      # 终端特性
      styled_underlines = true;
      support_kitty_keyboard_protocol = true;
      mouse_mode = true;
      scroll_buffer_size = 50000;

      # 剪贴板 & 序列化
      copy_on_select = true;
      serialize_pane_viewport = false;
      # serialization_interval = 120;      # 默认 60 秒，按需取消注释
    };

    # ═══ 插件配置（HM 模块暂不支持结构化，保留 extraConfig）═══
    extraConfig = ''
      plugins {
        about location="zellij:about"
        compact-bar location="zellij:compact-bar"
        configuration location="zellij:configuration"
        filepicker location="zellij:strider" {
          cwd "/"
        }
        plugin-manager location="zellij:plugin-manager"
        session-manager location="zellij:session-manager"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        tab-bar location="zellij:tab-bar"
        welcome-screen location="zellij:session-manager" {
          welcome_screen true
        }
      }
    '';
  };
}
