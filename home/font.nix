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

  # Fontconfig 配置 - 设置等宽字体为 LXGW WenKai Mono
  xdg.configFile."fontconfig/fonts.conf" = {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <!-- 设置默认等宽字体为 LXGW WenKai Mono -->
        <match target="pattern">
          <test name="family" compare="contains">
            <string>monospace</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Mono</string>
            <string>LXGW WenKai Screen</string>
          </edit>
        </match>

        <!-- 设置终端字体优先级 -->
        <match target="pattern">
          <test name="family" compare="contains">
            <string>Terminal</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Mono</string>
            <string>LXGW WenKai Screen</string>
          </edit>
        </match>

        <!-- 禁用位图字体 -->
        <match target="font">
          <test name="scalable" compare="not_eq">
            <bool>true</bool>
          </test>
          <edit name="scalable" mode="assign">
            <bool>true</bool>
          </edit>
        </match>
      </fontconfig>
    '';
    force = true;
  };

  # 设置 GTK 主题环境变量
  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 10";
  };

}