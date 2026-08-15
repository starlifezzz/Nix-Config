# /etc/nixos/modules/services/desktop-cosmic.nix
# COSMIC 桌面环境与显示管理 (cosmic-greeter, COSMIC, Fcitx5, XDG Portal)
# 分支: feat/cosmic —— 本文件替代 desktop.nix (KDE Plasma 6)
# 官方文档：
#   services.desktopManager.cosmic.enable: https://search.nixos.org/options?show=services.desktopManager.cosmic.enable
#   services.displayManager.cosmic-greeter.enable: https://search.nixos.org/options?show=services.displayManager.cosmic-greeter.enable
#   COSMIC NixOS Wiki: https://wiki.nixos.org/wiki/COSMIC
#   fcitx5 启动机制: i18n.inputMethod 选项说明 "Some services like i18n.inputMethod ... use XDG autostart files to start"
#     → https://search.nixos.org/options?show=services.xserver.desktopManager.runXdgAutostartIfNone
{ pkgs, lib, ... }:

{
  # ── Fcitx5 输入法（保留，与 KDE 分支一致）────────────────────
  # COSMIC (cosmic-comp) 实现 zwp_input_method_v2；
  # fcitx5 ≥ 5.1.12 支持该协议（当前 unstable 版本远超此线）。
  # fcitx5 由 i18n.inputMethod 生成的 XDG autostart 条目自动启动，
  # COSMIC session 遵循 XDG autostart 规范，无需 KWin InputMethod= 转发。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      kdePackages.fcitx5-chinese-addons
      kdePackages.fcitx5-configtool
      fcitx5-material-color
    ];
  };

  # ── COSMIC 桌面环境 ────────────────────────────────────────
  services.desktopManager.cosmic.enable = true;

  # COSMIC 登录管理器（替代 SDDM）
  services.displayManager.cosmic-greeter.enable = true;

  # COSMIC Wayland session（cosmic.desktop → defaultSession = "cosmic"）
  services.displayManager.defaultSession = "cosmic";

  # ── XDG 会话变量 ───────────────────────────────────────────
  environment.sessionVariables = {
    TZ = "Asia/Shanghai";
    XDG_CURRENT_DESKTOP = "COSMIC";
    XDG_SESSION_DESKTOP = "cosmic";
    DESKTOP_SESSION = "cosmic";
    NIXOS_OZONE_WL = "1"; # 强制 Electron 应用使用 Wayland
  };

  # ── XDG Portal - COSMIC 环境 ───────────────────────────────
  xdg.portal = {
    enable = true;
    # COSMIC 专用的 portal 实现 + GTK 文件选择器回退
    extraPortals = [
      pkgs.xdg-desktop-portal-cosmic
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "cosmic" "gtk" ];
    };
  };

  # ── D-Bus 配置（broker 以获得更好的 Portal 支持）─────────────
  services.dbus.enable = true;
  services.dbus.implementation = "broker";

  # dconf - GTK 配置后端
  programs.dconf.enable = true;

  # 打印服务（默认禁用，与 KDE 分支一致）
  services.printing.enable = false;
}
