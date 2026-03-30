# /etc/nixos/home/zellij.nix
# Zellij Terminal Multiplexer 配置
{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;

    extraConfig = ''
      // 添加到配置中
      general {
        serialization_interval 60000          // 减少序列化频率（默认 10 秒 → 60 秒）
        serialize_pane_viewport false         // 禁用面板视口序列化，减少内存占用
        styled_underlines true                // 启用样式下划线（如果终端支持）
        support_kitty_keyboard_protocol true  // 启用 Kitty 键盘协议
      }

      theme "gruvbox-dark"  // Gruvbox 主题（暖色调）

      // 添加默认 Shell
      default_shell "fish"

      // ═══════════════════════════════════════════════════════════
      // 鼠标模式 - 使用 Zellij 原生支持
      // ═══════════════════════════════════════════════════════════
      mouse_mode true

      // 自动复制到剪贴板
      copy_on_select true

      // ═══════════════════════════════════════════════════════════
      // 滚动优化 - 解决长输出选择时的自动滚动问题
      // ═══════════════════════════════════════════════════════════
      // 增加历史缓冲区大小（默认 10000 行 → 50000 行）
      scroll_buffer_size 50000
      
      // 调整鼠标滚动速度（关键！）
      // 数值越大，滚动越快。设置为极高的值实现快速连续滚动
      scroll_speed 20
      
      // 启用平滑滚动（如果支持）
      smooth_scroll true
      
      // ✅ 使用 Zellij 官方默认快捷键
      // 默认前缀：Ctrl+空格 (或 Ctrl+P)
      // 完整快捷键列表见：https://zellij.dev/documentation/keybindings.html

      // ═══════════════════════════════════════════════════════════
      // 插件配置
      // ═══════════════════════════════════════════════════════════
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

      // 后台加载插件（不阻塞启动）
      load_plugins {
      }

      // 禁用启动提示
      show_startup_tips false
    '';
  };
}
