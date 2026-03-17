{ config, pkgs, lib, ... }:

{
  # KDE Plasma 桌面环境配置
  home.pointerCursor = {
    gtk.enable = true;
    
    # X11/Wayland 指针主题
    name = "Papirus";
    package = pkgs.papirus-icon-theme;
    size = 24;
    x11.enable = true;
  };

  # 全局外观和主题
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "org.kde.breezetwilight.desktop";
  };


  # KWin Wayland 输入法配置
  xdg.configFile."kwinrc" = {
    text = ''
      [Desktops]
      Number=1
      Rows=1

      [ElectricBorders]
      BottomLeft=ApplicationLauncher

      [Tiling]
      padding=4

      [Wayland]
      InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';
    force = true;
  };


    # 设置 GTK 主题环境变量
  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 11";
    # 在 Wayland 下清空这些变量，让 Wayland 协议直接处理
    GTK_IM_MODULE = "";
    QT_IM_MODULE = "";
    XMODIFIERS = "@im=fcitx";
  };

}