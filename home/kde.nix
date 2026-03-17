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

  # KDE 配置文件
  xdg.configFile = {
    "gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
      '';
      force = true;
    };

    "gtk-4.0/settings.ini" = {
      text = ''
        [Settings]
      '';
      force = true;
    };

    "gtk-2.0/gtkrc" = {
      text = ''
        gtk-icon-theme-name="Papirus"
        gtk-font-name="LXGW WenKai Screen 10"
      '';
      force = true;
    };
  };

}