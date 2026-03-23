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
  # 用户软件包
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    jetbrains-mono
    fira-code
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

  # ═══════════════════════════════════════════════════════════
  # 启用 Home Manager
  # ═══════════════════════════════════════════════════════════
  programs.home-manager.enable = true;

  imports = [
    ./home.nix
    ./kde.nix
    # ./font.nix
    ./Alacritty.nix
    ./zellij.nix
  ];

}