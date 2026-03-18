/**
  字体配置 - 通过 Home Manager 管理
*/
{ config, pkgs, lib, ... }:

{

  
  # 启用 fontconfig
  fonts.fontconfig.enable = true;

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