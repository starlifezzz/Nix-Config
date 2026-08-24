# /etc/nixos/home/ghostty.nix
# Ghostty 终端模拟器配置
# 官方文档：https://ghostty.org/docs/configuration
# Home Manager: https://nix-community.github.io/home-manager/unstable/options.html#opt-programs.ghostty.enable
{ pkgs, ... }:

let
  ghostty-ime = pkgs.writeShellScriptBin "ghostty-ime" ''
    export SHELL="${pkgs.fish}/bin/fish"
    export GTK_IM_MODULE=fcitx5
    export XMODIFIERS=@im=fcitx5
    export GLFW_IM_MODULE=ibus  # Ghostty 官方 IME 桥接：fcitx5 通过 ibus 协议接入（已验证中文可输入）
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
      theme = "Lovelace";
      background-opacity = 0.92;
      background-opacity-cells = true; # ➕ 新增：zellij 内也透明
      background-blur = true; # ✅ 保留！官方合法，Plasma 上有效

      font-family = "LXGW WenKai Mono";
      font-size = 14;

      window-width = 110;
      window-height = 29;
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
    Exec=${ghostty-ime}/bin/ghostty-ime %U
    Icon=com.mitchellh.ghostty
    Terminal=false
    Type=Application
    Categories=System;TerminalEmulator;
    StartupWMClass=ghostty
  '';

}
