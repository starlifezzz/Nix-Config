# /etc/nixos/modules/services/desktop.nix
# 桌面环境与显示管理 (SDDM, Plasma6, Fcitx5, XDG Portal)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.desktopManager.plasma6.enable
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.displayManager.sddm.enable
{ pkgs, ... }:

{
  # i18n.inputMethod = {
  #   enable = true;
  #   type = "fcitx5";
  #   fcitx5.addons = with pkgs; [
  #     fcitx5-rime
  #     qt6Packages.fcitx5-chinese-addons
  #     qt6Packages.fcitx5-configtool
  #   ];
  # };

  # Fcitx5 输入法
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      kdePackages.fcitx5-chinese-addons
      kdePackages.fcitx5-configtool
    ];
  };

  # KDE Plasma 6 桌面环境
  services.desktopManager.plasma6.enable = true;

  # SDDM 显示管理器
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      General = {
        EnableAvatars = false;
      };
    };
  };

  # XDG 桌面环境变量 - 确保 Wayland 和 Portal 正确识别 KDE 环境
  environment.sessionVariables = {
    TZ = "Asia/Shanghai";
    XDG_CURRENT_DESKTOP = "KDE";
    XDG_MENU_PREFIX = "kde-";
    XDG_SESSION_DESKTOP = "KDE";
    DESKTOP_SESSION = "plasma";
    KDE_FULL_SESSION = "true";
    NIXOS_OZONE_WL = "1"; # 强制 Electron 应用使用 Wayland
  };

  # XDG Portal - KDE Plasma 环境
  xdg.portal = {
    enable = true;
    # extraPortals = [
    #   pkgs.kdePackages.xdg-desktop-portal-kde
    # ];
    config = {
      common.default = [ "kde" ];
    };
  };

  # D-Bus 配置 - 使用 broker 以获得更好的 Portal 支持
  services.dbus.enable = true;
  services.dbus.implementation = "broker";

  # dconf - KDE/GTK 配置后端
  programs.dconf.enable = true;

  # 打印服务（默认禁用）
  services.printing.enable = false;
}