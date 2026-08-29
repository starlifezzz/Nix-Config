# /etc/nixos/home/ghostty.nix
# Ghostty 终端模拟器配置
# 官方文档：https://ghostty.org/docs/configuration
# Home Manager: https://nix-community.github.io/home-manager/unstable/options.html#opt-programs.ghostty.enable
{ pkgs, ... }:

let
  ghostty-ime = pkgs.writeShellScriptBin "ghostty-ime" ''
    export SHELL="${pkgs.fish}/bin/fish"
    # 方案 1：GTK_IM_MODULE=wayland → Wayland text-input 协议
    # 依据: Ghostty discussion #3628，fcitx5 开发者 wengxt 确认该方式总是有效，
    #       且根治 Ghostty key-release 过滤 bug（Ctrl+Shift 切换输入法失效问题）
    # 说明: Ghostty 主 runtime 是 GTK，GLFW_IM_MODULE 无效（官方 collaborator 确认）
    export GTK_IM_MODULE=wayland
    # XWayland 应用（如从终端启动的 vscode）回退用 fcitx5 模块
    export XMODIFIERS=@im=fcitx5
    exec ${pkgs.ghostty}/bin/ghostty "$@"
  '';
in
{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installVimSyntax = true;
    installBatSyntax = true;

    # ════════════════════════════════════════════════════════
    # 美化配置 - 透明背景、Lovelace 主题
    # ════════════════════════════════════════════════════════
    settings = {
      command = "${pkgs.zellij}/bin/zellij";
      # theme = "Lovelace";
      theme = "dankcolors";
      background-opacity = 0.92;
      background-opacity-cells = true; # ➕ 新增：zellij 内也透明
      background-blur = true; # ✅ 保留！官方合法，Plasma 上有效

      font-family = "LXGW WenKai Mono";
      font-size = 14;

      window-width = 126;
      window-height = 34;
      window-padding-x = 8;
      window-padding-y = 4;
      window-decoration = "auto";
      window-theme = "auto";
      window-padding-balance = true;
      window-padding-color = "extend"; # ➕ 新增：padding 颜色延伸

      gtk-single-instance = false;
      linux-cgroup = "always"; # ➕ 新增：补偿 single-instance=false

      cursor-style = "bar";
      cursor-style-blink = true;

      # ➕ 官方支持，替代写死 term
      shell-integration-features = "cursor,sudo,title,ssh-env,ssh-terminfo,path"; # ➕ 加 path
      confirm-close-surface = false;
      copy-on-select = false;
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

  home.packages = [ ghostty-ime ];

  # ✅ 用 home.file 强制写入
  home.file.".local/share/applications/com.mitchellh.ghostty.desktop".force = true;
  home.file.".local/share/applications/com.mitchellh.ghostty.desktop".text = ''
    [Desktop Entry]
    Name=Ghostty
    Exec=${ghostty-ime}/bin/ghostty-ime
    Icon=com.mitchellh.ghostty
    Terminal=false
    Type=Application
    Categories=System;TerminalEmulator;
    StartupWMClass=ghostty
  '';

}
