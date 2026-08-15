{ pkgs, lib, ... }:

let
  setKdeShortcuts = pkgs.writeShellScript "set-kde-shortcuts" ''
    f="$HOME/.config/kglobalshortcutsrc"
    mkdir -p "$HOME/.config"
    touch "$f"

    set_shortcut() {
      local group="$1" key="$2" value="$3"
      # 幂等：先删除该 group 的全部旧段（含重复），再追加唯一一段
      awk -v g="[$group]" '
        $0 == g { skip = 1; next }
        skip && /^\[/ { skip = 0 }
        skip { next }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
      printf '\n[%s]\n%s=%s\n' "$group" "$key" "$value" >> "$f"
    }

    remove_group() {
      local group="$1"
      awk -v g="[$group]" '
        $0 == g { skip = 1; next }
        skip && /^\[/ { skip = 0 }
        skip { next }
        { print }
      ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
    }

    # 清理已卸载的 ghostty 快捷键段（避免 Ctrl+Alt+T 冲突）
    remove_group "services][com.mitchellh.ghostty.desktop"

    set_shortcut "com.qq.QQ" "2D59F3ECB6A4CF6AFB00764B70034BC9-Ctrl+Alt+L" "Ctrl+Alt+L,Ctrl+Alt+L,Electron shortcut Ctrl+Alt+L"
    set_shortcut "com.qq.QQ" "50CD026BD913BFEE35352B1D2455BC71-Ctrl+Alt+C" "Ctrl+Alt+C,Ctrl+Alt+C,Electron shortcut Ctrl+Alt+C"
    set_shortcut "com.qq.QQ" "8AAB8812708223DBC78147F0CD9C498B-Ctrl+Alt+Z" "Ctrl+Alt+Z,Ctrl+Alt+Z,Electron shortcut Ctrl+Alt+Z"
    set_shortcut "services][Alacritty.desktop" "_launch" "Ctrl+Alt+T"
    set_shortcut "services][org.kde.spectacle.desktop" "RectangularRegionScreenShot" "Ctrl+Alt+A	Meta+Shift+Print"
  '';
in
{
  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.package = pkgs.kdePackages.breeze;
    style.name = "breeze";
  };

  home.activation.kdeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "ColorScheme" "BreezeLight"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "font" "LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "menuFont" "LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "smallestReadableFont" "LXGW WenKai Screen,8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "toolBarFont" "LXGW WenKai Screen,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "accentColorFromWallpaper" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "XftHintStyle" "hintslight"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "General" --key "XftSubPixel" "none"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "Icons" --key "Theme" "Papirus"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KDE" --key "LookAndFeelPackage" "org.kde.breezetwilight.desktop"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KDE" --key "contrast" "4"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Allow Expansion" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Automatically select filename extension" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Breadcrumb Navigation" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Decoration position" "2"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show Full Path" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show Inline Previews" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show Preview" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show Speedbar" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Show hidden files" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Sort by" "Name"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Sort directories first" "true"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Sort hidden files last" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Sort reversed" "false"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "Speedbar Width" "90"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "KFileDialog Settings" --key "View Style" "DetailTree"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "activeBackground" "227,229,231"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "activeBlend" "227,229,231"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "activeForeground" "35,38,41"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "inactiveBackground" "239,240,241"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "inactiveBlend" "239,240,241"
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group "WM" --key "inactiveForeground" "112,125,138"
    run ${setKdeShortcuts}
  '';

  xdg.configFile."kwinrc" = {
    text = ''
      [Desktops]
      Number=1
      Rows=1

      [ElectricBorders]
      BottomLeft=ApplicationLauncher

      [Tiling]
      padding=4

      # 恢复 KWin InputMethod= 行（2026-08-15）
      # 原因: 2026-08-13 撤销后微信/QQ 无法输入中文。
      # 依据: 旧机（Ventoy 复制配置，20260723）同一行存在且微信可正常输入，
      #       证实该行不是冲突元凶，而是 KWin 转发输入所必需。
      # 官方机制: KWin 通过 desktop 路径指定输入法，见 kwinrc(5) [Wayland] 组。
      [Wayland]
      InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';
    force = true;
  };

  # home.sessionVariables（GTK_IM_MODULE/QT_IM_MODULE/XMODIFIERS/SDL_IM_MODULE）
  # 已迁移至 ./fcitx5.nix，集中管理输入法相关环境变量。
  # 风险提示: Wayland 下 GTK/QT IM module 必须留空，删除会导致部分程序无法输入中文。

  dconf.enable = true;
}
