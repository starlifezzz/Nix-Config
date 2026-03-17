{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 字体配置 - 通过 Home Manager 管理
  # ═══════════════════════════════════════════════════════════
  
  # 启用 fontconfig
  fonts.fontconfig.enable = true;

  # 安装字体包
  home.packages = with pkgs; [
    lxgw-wenkai               # 霞鹜文楷
    lxgw-wenkai-screen        # 霞鹜文楷屏幕版
    wqy_zenhei                # 文泉驿正黑
    wqy_microhei              # 文泉驿微米黑
    noto-fonts-cjk-sans       # Noto 无衬线中文字体
    noto-fonts-cjk-serif      # Noto 衬线中文字体
    source-han-sans           # 思源黑体
    source-han-serif          # 思源宋体
    jetbrains-mono            # JetBrains Mono
    fira-code                 # Fira Code
  ];

  # 字体配置文件
  xdg.configFile."fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <!-- 基础设置 -->
      <match target="font">
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
        <edit name="lcdfilter" mode="assign"><const>default</const></edit>
      </match>

      <!-- 强制 LXGW WenKai Screen 为首选字体 -->
      <alias>
        <family>monospace</family>
        <prefer>
          <family>LXGW WenKai Screen</family>
          <family>JetBrains Mono</family>
          <family>Fira Code</family>
          <family>Hack</family>
          <family>DejaVu Sans Mono</family>
        </prefer>
      </alias>

      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>LXGW WenKai Screen</family>
          <family>Noto Sans CJK SC</family>
          <family>WenQuanYi Micro Hei</family>
          <family>WenQuanYi Zen Hei</family>
          <family>Noto Sans</family>
          <family>DejaVu Sans</family>
        </prefer>
      </alias>

      <alias>
        <family>serif</family>
        <prefer>
          <family>LXGW WenKai Screen</family>
          <family>Noto Serif CJK SC</family>
          <family>Source Han Serif SC</family>
          <family>Noto Serif</family>
          <family>DejaVu Serif</family>
        </prefer>
      </alias>

      <!-- 针对所有应用的通用字体设置 -->
      <match target="pattern">
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
        </edit>
      </match>

      <!-- 中文语言特定设置 -->
      <match target="pattern">
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
          <string>JetBrains Mono</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
          <string>Noto Sans CJK SC</string>
          <string>WenQuanYi Micro Hei</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
          <string>Noto Serif CJK SC</string>
          <string>Source Han Serif SC</string>
        </edit>
      </match>

      <!-- 为 Qt/KDE 应用特别优化 -->
      <match target="pattern">
        <test name="prgname">
          <string>kate</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="prgname">
          <string>dolphin</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="prgname">
          <string>konsole</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Screen</string>
        </edit>
      </match>
    </fontconfig>
  '';

  # KDE 字体配置文件
  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorSchemeHash=f08fce0cfa831db116d71bd9c8b9110bd75731be
    XftHintStyle=hintslight
    XftSubPixel=rgb
    accentColorFromWallpaper=true
    
    # 主要字体设置 - 使用正确的字体名称
    font=LXGW WenKai Screen,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
    menuFont=LXGW WenKai Screen,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
    smallestReadableFont=LXGW WenKai Screen,9,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
    toolBarFont=LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,0
    fixed=LXGW WenKai Screen,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,0

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

  # GTK 字体设置
  xdg.configFile."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-font-name=LXGW WenKai Screen 11
    gtk-icon-theme-name=Papirus
  '';

  xdg.configFile."gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-font-name=LXGW WenKai Screen 11
    gtk-icon-theme-name=Papirus
  '';

  xdg.configFile."gtk-2.0/gtkrc".text = ''
    gtk-font-name="LXGW WenKai Screen 11"
    gtk-icon-theme-name="Papirus"
  '';

  # 设置 GTK 主题环境变量
  home.sessionVariables = {
    GTK_FONT_NAME = "LXGW WenKai Screen 11";
  };
}