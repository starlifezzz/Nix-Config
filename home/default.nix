# /etc/nixos/home/default.nix
{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "25.11";

  # 禁用 Nixpkgs 版本检查（因为我们在用 unstable）
  home.enableNixpkgsReleaseCheck = false;

  # ═══════════════════════════════════════════════════════════
  # 启用 Home Manager systemd 服务 - 关键配置！
  # ═══════════════════════════════════════════════════════════
  programs.home-manager.enable = true;

  # ═══════════════════════════════════════════════════════════
  # XDG 桌面集成
  # ═══════════════════════════════════════════════════════════
  # 启用 XDG 规范支持（管理 XDG 目录、MIME 类型等）
  xdg.enable = true;

  # 配置 XDG 用户目录（符合 freedesktop.org 标准）
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
  };

  # 配置 MIME 类型关联
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 桌面快捷方式 - 手动指定 .desktop 文件链接
  # ═══════════════════════════════════════════════════════════
  # Home Manager 不会自动扫描 home.packages 创建快捷方式
  # 必须使用 xdg.dataFile 显式链接到 ~/.local/share/applications/
  xdg.dataFile."applications/net.lutris.Lutris.desktop".source = 
    "${pkgs.lutris}/share/applications/net.lutris.Lutris.desktop";

  # ═══════════════════════════════════════════════════════════
  # 用户软件包
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    jetbrains-mono
    fira-code

      # 游戏相关
    pkgs.lutris
  ];

  # ═══════════════════════════════════════════════════════════
  # 环境变量
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    XDG_DATA_DIRS = lib.makeSearchPath "" [
      "$HOME/.local/share"
      "/run/current-system/sw/share"
      "/nix/var/nix/profiles/default/share"
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];

    # ═══════════════════════════════════════════════════════════
    # Wayland 专用配置
    # ═══════════════════════════════════════════════════════════
    # 启用 Firefox 的 Wayland 支持
    MOZ_ENABLE_WAYLAND = "1";
    # Qt 应用优先使用 Wayland，回退到 XCB
    QT_QPA_PLATFORM = "wayland;xcb";
    # GTK 应用优先使用 Wayland，回退到 X11
    GDK_BACKEND = "wayland,x11";
    # 明确会话类型为 Wayland
    XDG_SESSION_TYPE = "wayland";
    # Clutter 工具包使用 Wayland
    CLUTTER_BACKEND = "wayland";
    # SDL 应用使用 Wayland
    SDL_VIDEODRIVER = "wayland";
    # Electron 应用自动选择平台
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

  };

  imports = [
    ./home.nix
    ./kde.nix
    # ./font.nix
    ./Alacritty.nix
    ./zellij.nix
  ];

}