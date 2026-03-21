{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.flatpak-fonts;
  targetUser = if cfg.userName != "" then cfg.userName else "zhangchongjie";
in
{
  options.services.flatpak-fonts = {
    enable = mkEnableOption (mdDoc "自动复制系统字体到用户目录供 Flatpak 使用");
    
    userName = mkOption {
      type = types.str;
      default = "";
      description = "目标用户名，留空则使用默认用户";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "sync-flatpak-fonts" ''
        #!/usr/bin/env bash
        set -e

        USER_HOME="/home/${targetUser}"
        USER_FONT_DIR="$USER_HOME/.local/share/fonts"

        if [ ! -d "$USER_HOME" ]; then
          echo "错误：用户 ${targetUser} 的主目录不存在"
          exit 1
        fi

        echo "🔤 为用户 ${targetUser} 设置 Flatpak字体..."
        mkdir -p "$USER_FONT_DIR"

        TEMP_COUNT=$(mktemp)
        echo "0 0" > "$TEMP_COUNT"

        link_font() {
          local font_path="$1"
          local font_name="$(basename "$font_path")"
          local dest_path="$USER_FONT_DIR/$font_name"

          if [ -L "$dest_path" ] || [ -f "$dest_path" ]; then
            echo "    ⏭️  已存在：$font_name"
            return 0
          fi

          if [ -f "$font_path" ] && [ -s "$font_path" ]; then
            if ln -sf "$font_path" "$dest_path" 2>/dev/null; then
              echo "    ✓ 链接：$font_name"
              read new exist < "$TEMP_COUNT"
              echo "$((new + 1)) $exist" > "$TEMP_COUNT"
              return 0
            fi
          fi
          return 0
        }

        FONT_SOURCES="/run/current-system/sw/share/fonts /nix/var/nix/profiles/system/sw/share/fonts"

        for SOURCE_DIR in $FONT_SOURCES; do
          if [ -d "$SOURCE_DIR" ]; then
            echo "  从 $SOURCE_DIR 搜索字体..."
            while read -r FONT; do
              link_font "$FONT"
            done < <(find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null)
          fi
        done

        read NEW_COUNT EXIST_COUNT < "$TEMP_COUNT"
        rm -f "$TEMP_COUNT"

        if [ "$NEW_COUNT" -gt 0 ]; then
          echo "  更新字体缓存..."
          sudo -u ${targetUser} fc-cache -f "$USER_FONT_DIR" 2>/dev/null || true
          echo "✅ 创建了 $NEW_COUNT 个新字体链接"
        else
          echo "✅ 所有字体已存在，无需操作"
        fi

        echo "字体目录：$USER_FONT_DIR"
        
        echo "🔓 设置 Flatpak 权限..."
        sudo -u ${targetUser} flatpak override --user --filesystem=~/.local/share/fonts:ro 2>&1 || echo "警告：flatpak override 失败"
        sudo -u ${targetUser} flatpak override --user --filesystem=xdg-data/fonts:create 2>&1 || echo "警告：flatpak override 失败"
        echo "✅ Flatpak 权限设置完成"
      '')
    ];

    system.activationScripts.setupFlatpakFonts = {
      text = ''
        echo "🔄 设置 Flatpak字体..."

        USER_HOME="/home/${targetUser}"
        USER_FONT_DIR="$USER_HOME/.local/share/fonts"

        if [ -d "$USER_HOME" ]; then
          mkdir -p "$USER_FONT_DIR"

          FONT_SOURCES="/run/current-system/sw/share/fonts /nix/var/nix/profiles/system/sw/share/fonts"

          for SOURCE_DIR in $FONT_SOURCES; do
            if [ -d "$SOURCE_DIR" ]; then
              find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | \
                while read FONT; do
                  FONT_NAME=$(basename "$FONT")
                  DEST_PATH="$USER_FONT_DIR/$FONT_NAME"
                  if [ ! -L "$DEST_PATH" ] && [ ! -f "$DEST_PATH" ]; then
                    ln -sf "$FONT" "$DEST_PATH" 2>/dev/null || true
                  fi
                done
            fi
          done

          chown -R ${targetUser}:users "$USER_FONT_DIR" 2>/dev/null || true
          chmod -R 755 "$USER_FONT_DIR"

          sudo -u ${targetUser} fc-cache -f "$USER_FONT_DIR" 2>/dev/null || true

          echo "⚠️  尝试设置 Flatpak 权限..."
          sudo -u ${targetUser} flatpak override --user --filesystem=~/.local/share/fonts:ro 2>&1 || true
          sudo -u ${targetUser} flatpak override --user --filesystem=xdg-data/fonts:create 2>&1 || true
          
          echo "✅ Flatpak字体设置完成"
        else
          echo "  警告：用户 ${targetUser} 的主目录不存在，跳过"
        fi
      '';
      deps = [ "users" "groups" ];
    };

  };
}