{ config, lib, pkgs, ... }:

{
  # 系统字体配置

  # 启用字体目录支持
  fonts.fontDir.enable = true;

  # 启用默认字体
  fonts.enableDefaultPackages = lib.mkDefault true;
  fonts.enableGhostscriptFonts = lib.mkDefault true;

  # 定义要安装的字体包
  fonts.packages = with pkgs; [
    # 中文和东亚字体
    lxgw-wenkai               # 霞鹜文楷
    lxgw-wenkai-screen        # 霞鹜文楷屏幕版
    wqy_zenhei                # 文泉驿正黑
    wqy_microhei              # 文泉驿微米黑


    # 等宽字体 - 使用单独的 nerdfonts 包
    jetbrains-mono           # JetBrains Mono
    fira-code               # Fira Code
    hack-font               # Hack
    dejavu_fonts            # DejaVu

    # 西文字体
    liberation_ttf          # Liberation
    liberation-sans-narrow
    corefonts               # Microsoft 核心字体
    source-code-pro         # 编程字体
    source-sans-pro
    source-serif-pro

    # 符号字体
    noto-fonts-color-emoji  # Noto 彩色表情符号
    font-awesome            # Font Awesome 图标
    material-design-icons   # Material Design 图标

    # 其他中文字体
    source-han-sans         # 思源黑体
    source-han-serif        # 思源宋体
    sarasa-gothic           # 更纱黑体/等距更纱黑体
  ];

  # 字体配置
  fonts.fontconfig = {
    enable = true;

    # 字体渲染设置
    antialias = true;
    hinting.enable = true;
    subpixel = {
      rgba = "rgb";  # RGB 子像素渲染
      lcdfilter = "default";  # LCD 滤镜
    };

    # 默认字体设置
    defaultFonts = {
      # 衬线字体 (Serif)
      serif = [
        "LXGW WenKai"        # 霞鹜文楷
        "Noto Serif CJK SC"  # Noto 衬线中文简体
        "Noto Serif"         # Noto 衬线
        "DejaVu Serif"       # DejaVu 衬线
      ];

      # 无衬线字体 (Sans-serif)
      sansSerif = [
        "WenQuanYi Micro Hei"  # 文泉驿微米黑
        "Noto Sans CJK SC"     # Noto 无衬线中文简体
        "Noto Sans"            # Noto 无衬线
        "DejaVu Sans"          # DejaVu 无衬线
      ];

      # 等宽字体 (Monospace)
      monospace = [
        "JetBrains Mono"    # JetBrains Mono
        "Fira Code"         # Fira Code
        "Hack"             # Hack
        "LXGW WenKai Mono"  # 霞鹜文楷等宽
        "DejaVu Sans Mono"  # DejaVu 等宽
      ];

      # 表情符号字体
      emoji = [
        "Noto Color Emoji"  # Noto 彩色表情符号
        "Noto Emoji"        # Noto 表情符号
      ];
    };

    # 针对中文的字体替换规则
    localConf = ''
      <!-- 中文字体替换规则 -->
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>WenQuanYi Micro Hei</family>
          <family>Noto Sans CJK SC</family>
          <family>Noto Sans</family>
          <family>DejaVu Sans</family>
        </prefer>
      </alias>
      <alias>
        <family>serif</family>
        <prefer>
          <family>LXGW WenKai</family>
          <family>Noto Serif CJK SC</family>
          <family>Noto Serif</family>
          <family>DejaVu Serif</family>
        </prefer>
      </alias>
      <alias>
        <family>monospace</family>
        <prefer>
          <family>JetBrains Mono</family>
          <family>LXGW WenKai Mono</family>
          <family>Fira Code</family>
          <family>DejaVu Sans Mono</family>
        </prefer>
      </alias>

      <!-- 中文语言特定设置 -->
      <match target="pattern">
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>sans-serif</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>WenQuanYi Micro Hei</string>
          <string>Noto Sans CJK SC</string>
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
          <string>LXGW WenKai</string>
          <string>Noto Serif CJK SC</string>
        </edit>
      </match>

      <match target="pattern">
        <test name="lang" compare="contains">
          <string>zh</string>
        </test>
        <test name="family">
          <string>monospace</string>
        </test>
        <edit name="family" mode="prepend" binding="strong">
          <string>LXGW WenKai Mono</string>
          <string>JetBrains Mono</string>
        </edit>
      </match>
    '';
  };

  # 字体环境变量
  environment.variables = {
    # 字体渲染设置
    FREETYPE_PROPERTIES = "truetype:interpreter-version=40 cff:no-stem-darkening=0";
    # 针对高分屏的字体渲染
    GDK_SCALE = "1";
    GDK_DPI_SCALE = "1";
  };
}
