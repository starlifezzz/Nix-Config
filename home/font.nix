{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 字体配置 - 通过 Home Manager 管理
  # ═══════════════════════════════════════════════════════════
  
  # 启用 fontconfig
  fonts.fontconfig.enable = true;

  # 安装字体包
  home.packages = with pkgs; [
    lxgw-wenkai
    lxgw-wenkai-screen  #等宽字体
    wqy_zenhei
    wqy_microhei
    # noto-fonts-cjk-sans
    # noto-fonts-cjk-serif
    source-han-sans
    source-han-serif
    jetbrains-mono
    fira-code
  ];

  # KDE 字体配置文件 - 使用 LXGW WenKai Screen
  xdg.configFile."kdeglobals" = {
    text = ''
      [General]
      ColorSchemeHash=f08fce0cfa831db116d71bd9c8b9110bd75731be
      XftHintStyle=hintslight
      XftSubPixel=rgb
      accentColorFromWallpaper=true
      
      # 主要字体设置 - 使用 LXGW WenKai Screen
      font=LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
      menuFont=LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
      smallestReadableFont=LXGW WenKai Screen,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
      toolBarFont=LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
      fixed=LXGW WenKai Screen Mono,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0

      [Icons]
      Theme=Papirus

      [KDE]
      LookAndFeelPackage=org.kde.breezetwilight.desktop

      [WM]
      activeBackground=227,229,231
      activeBlend=227,229,231
      activeFont=LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
      activeForeground=35,38,41
      inactiveBackground=239,240,241
      inactiveBlend=239,240,241
      inactiveForeground=112,125,138
    '';
    force = true;
  };

  # GTK 字体设置
  xdg.configFile."gtk-3.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-font-name=LXGW WenKai Screen 10
      gtk-icon-theme-name=Papirus
    '';
    force = true;
  };

  xdg.configFile."gtk-4.0/settings.ini" = {
    text = ''
      [Settings]
      gtk-font-name=LXGW WenKai Screen 10
      gtk-icon-theme-name=Papirus
    '';
    force = true;
  };

  xdg.configFile."gtk-2.0/gtkrc" = {
    text = ''
      gtk-font-name="LXGW WenKai Screen 10"
      gtk-icon-theme-name="Papirus"
    '';
    force = true;
  };

  # 设置 GTK 主题环境变量
  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 10";
  };

}