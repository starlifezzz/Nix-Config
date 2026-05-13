# /etc/nixos/home/ghostty.nix
# Ghostty 终端模拟器配置
# 官方文档：https://ghostty.org/docs/configuration
# Home Manager: https://nix-community.github.io/home-manager/unstable/options.html#opt-programs.ghostty.enable
{  pkgs,  ... }:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installVimSyntax = true;
    installBatSyntax = true;

    # ════════════════════════════════════════════════════════
    # 美化配置 - 透明背景、Catppuccin 主题
    # ════════════════════════════════════════════════════════
    settings = {
      command = "${pkgs.zellij}/bin/zellij";

      theme = "Lovelace";
      background-opacity = 0.92;
      background-blur = true;
      window-decoration = "auto";
      window-theme = "auto";

      font-family = "LXGW WenKai Mono";
      font-size = 14;
      font-feature = [
        "calt"
        "liga"
      ];

      # 设置合理的默认窗口尺寸，避免过小或过大
      window-width = 110;
      window-height = 31;
      window-padding-x = 8;
      window-padding-y = 4;
      window-save-state = "never";
      window-colorspace = "display-p3";
      window-vsync = true;

      # 确保窗口不会启动时最大化
      # window-maximized = false;

      gtk-single-instance = true;  # 必须设为 true 以匹配桌面文件

      cursor-style = "bar";
      cursor-style-blink = true;

      term = "xterm-256color";
      shell-integration = "zsh";
      confirm-close-surface = false;

      copy-on-select = "clipboard";
      mouse-hide-while-typing = true;

      keybind = [
        "super+c=copy_to_clipboard"
        "super+v=paste_from_clipboard"
        "super+plus=increase_font_size:1"
        "super+minus=decrease_font_size:1"
        "super+0=reset_font_size"
      ];
    };
  };
}