# /etc/nixos/home/ghostty.nix
# Ghostty 终端模拟器配置
# 官方文档：https://ghostty.org/docs/configuration
# Home Manager: https://nix-community.github.io/home-manager/unstable/options.html#opt-programs.ghostty.enable
{ pkgs, ... }:

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
      theme = "Lovelace"; # 注释里的 Catppuccin 改掉
      background-opacity = 0.92;
      background-blur = true; # ✅ 保留！官方合法，Plasma 上有效

      font-family = "LXGW WenKai Mono";
      font-size = 14;
      font-feature = [
        "calt"
        "liga"
      ];

      window-width = 110;
      window-height = 29;
      window-padding-x = 8;
      window-padding-y = 4;
      window-decoration = "auto";
      window-theme = "auto";
      window-padding-balance = true;

      gtk-single-instance = false;

      cursor-style = "bar";
      cursor-style-blink = true;

      shell-integration-features = [
        "cursor"
        "sudo"
        "title"
        "ssh-env"
        "ssh-terminfo"
      ]; # ➕ 官方支持，替代写死 term

      confirm-close-surface = false;
      copy-on-select = "clipboard";
      mouse-hide-while-typing = true;

      # 可选增强（官方均存在）
      clipboard-trim-trailing-spaces = true;
      clipboard-paste-protection = true;
      adjust-cell-height = 2; # 增量+2，中文行距更透气
      minimum-contrast = 1.1; # 可选

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