{ config, pkgs, lib, ... }:

{
  fonts.fontconfig.enable = true;

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

  xdg.configFile."fontconfig/fonts.conf" = {
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <test name="family" compare="contains">
            <string>monospace</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Mono</string>
            <string>LXGW WenKai Screen</string>
          </edit>
        </match>

        <match target="pattern">
          <test name="family" compare="contains">
            <string>Terminal</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Mono</string>
            <string>LXGW WenKai Screen</string>
          </edit>
        </match>

        <match target="pattern">
          <test name="family" compare="contains">
            <string>sans-serif</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Screen</string>
            <string>Source Han Sans CN</string>
            <string>Noto Sans CJK SC</string>
          </edit>
        </match>
        
        <match target="pattern">
          <test name="family" compare="contains">
            <string>serif</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>LXGW WenKai Screen</string>
            <string>Source Han Serif CN</string>
            <string>Noto Serif CJK SC</string>
          </edit>
        </match>

      </fontconfig>
    '';
    force = true;
  };

  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 10";
  };

}