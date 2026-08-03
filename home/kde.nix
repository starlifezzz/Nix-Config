{ pkgs, lib, ... }:

let
  setKdeShortcuts = pkgs.writeShellScript "set-kde-shortcuts" ''
    f="$HOME/.config/kglobalshortcutsrc"
    mkdir -p "$HOME/.config"
    touch "$f"

    set_shortcut() {
      local group="$1" key="$2" value="$3"
      if grep -q "^\[$group\]" "$f"; then
        if grep -q "^$key=" "$f"; then
          sed -i "s|^$key=.*|$key=$value|" "$f"
        else
          sed -i "/^\[$group\]/a $key=$value" "$f"
        fi
      else
        printf '\n[%s]\n%s=%s\n' "$group" "$key" "$value" >> "$f"
      fi
    }

    set_shortcut "com.qq.QQ" "2D59F3ECB6A4CF6AFB00764B70034BC9-Ctrl+Alt+L" "Ctrl+Alt+L,Ctrl+Alt+L,Electron shortcut Ctrl+Alt+L"
    set_shortcut "com.qq.QQ" "50CD026BD913BFEE35352B1D2455BC71-Ctrl+Alt+C" "Ctrl+Alt+C,Ctrl+Alt+C,Electron shortcut Ctrl+Alt+C"
    set_shortcut "com.qq.QQ" "8AAB8812708223DBC78147F0CD9C498B-Ctrl+Alt+Z" "Ctrl+Alt+Z,Ctrl+Alt+Z,Electron shortcut Ctrl+Alt+Z"
    set_shortcut "services][com.mitchellh.ghostty.desktop" "_launch" "Ctrl+Alt+T"
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

      [Wayland]
      InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop
      VirtualKeyboardEnabled=true
    '';
    force = true;
  };

  home.sessionVariables = {
    GTK_IM_MODULE = "";
    QT_IM_MODULE = "";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
  };

  dconf.enable = true;
}