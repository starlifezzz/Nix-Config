{ config, pkgs, lib, ... }:

let
  fontSetupScript = pkgs.writeShellScriptBin "setup-user-fonts" ''
    #!/usr/bin/env bash
    set -e
    
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    echo "🔗 创建字体符号链接..."
    
    for pkg in ${pkgs.lxgw-wenkai-screen} ${pkgs.lxgw-wenkai} ${pkgs.source-han-sans} ${pkgs.source-han-serif}; do
      if [ -d "$pkg/share/fonts" ]; then
        find "$pkg/share/fonts" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" \) -exec ln -sf {} "$FONT_DIR/" \;
      fi
    done
    
    echo "✅ 用户字体符号链接创建完成"
    
    echo "🔄 更新字体缓存..."
    fc-cache -fv "$FONT_DIR" 2>&1 | grep -v "failed" || true
    
    echo "🔓 设置 Flatpak 权限..."
    flatpak override --user --filesystem=~/.local/share/fonts:ro
    flatpak override --user --filesystem=xdg-data/fonts:create
    echo "✅ Flatpak 权限设置完成"
  '';
in
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
            <string>WenQuanYi Zen Hei</string>
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
            <string>WenQuanYi Micro Hei</string>
          </edit>
        </match>

        <match target="font">
          <test name="scalable" compare="not_eq">
            <bool>true</bool>
          </test>
          <edit name="scalable" mode="assign">
            <bool>true</bool>
          </edit>
        </match>
        
        <dir>~/.local/share/fonts</dir>
      </fontconfig>
    '';
    force = true;
  };

  home.packages = [ fontSetupScript ];

  home.activation.setupFonts = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "🔤 设置用户字体..."
    ${fontSetupScript}/bin/setup-user-fonts || true
  '';

  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 10";
  };

}