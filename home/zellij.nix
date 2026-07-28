# /etc/nixos/home/zellij.nix
# Zellij Terminal Multiplexer 配置
# /etc/nixos/home/zellij.nix
# Zellij Terminal Multiplexer 配置

{
  programs.zellij = {
    enable = true;

    extraConfig = ''
      // ═══ 基础设置 ═══
      default_shell "fish"
      theme "gruvbox-dark"
      show_startup_tips false

      // ═══ 终端特性 ═══
      styled_underlines true
      support_kitty_keyboard_protocol true
      mouse_mode true
      scroll_buffer_size 50000

      // ═══ 剪贴板 ═══
      copy_on_select true

      // ═══ 会话序列化优化 ═══
      // 默认就是 60 秒，无需修改；如要调整：
      // serialization_interval 120
      serialize_pane_viewport false

      // ═══ 插件配置 ═══
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
