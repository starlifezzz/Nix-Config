{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.flatpak-fonts;
  # 从系统用户配置获取用户名，或允许手动指定
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
    # 1. 不再重复定义字体包，由 fonts.nix 统一管理
    # fonts.packages 已在 fonts.nix 中定义

    # 2. 保留同步脚本供手动执行
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

        echo "🔤 为用户 ${targetUser} 设置 Flatpak 字体..."
        mkdir -p "$USER_FONT_DIR"

        # 使用临时文件统计，避免子 shell 问题
        TEMP_COUNT=$(mktemp)
        echo "0 0" > "$TEMP_COUNT"

        copy_font() {
          local font_path="$1"
          local font_name="$(basename "$font_path")"
          local dest_path="$USER_FONT_DIR/$font_name"

          if [ -f "$USER_FONT_DIR/$font_name" ]; then
            echo "    ⏭️  跳过：$font_name"
            return 0
          fi

          if [ -f "$font_path" ] && [ -s "$font_path" ]; then
            if cp -f "$font_path" "$dest_path" 2>/dev/null; then
              echo "    ✓ 复制：$font_name"
              # 更新计数
              read new exist < "$TEMP_COUNT"
              echo "$((new + 1)) $exist" > "$TEMP_COUNT"
              return 0
            fi
          fi
          return 0
        }

        # 从系统字体目录查找
        SYSTEM_FONT_DIRS="/nix/var/nix/profiles/system/sw/share/fonts"

        for SOURCE_DIR in $SYSTEM_FONT_DIRS; do
          if [ -d "$SOURCE_DIR" ]; then
            echo "  从 $SOURCE_DIR 搜索字体..."
            # ✅ 使用进程替换避免子 shell
            while read -r FONT; do
              copy_font "$FONT"
            done < <(find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null)
          fi
        done

        # 读取最终计数
        read NEW_COUNT EXIST_COUNT < "$TEMP_COUNT"
        rm -f "$TEMP_COUNT"

        if [ "$NEW_COUNT" -gt 0 ]; then
          echo "  更新字体缓存..."
          sudo -u ${targetUser} fc-cache -f "$USER_FONT_DIR" 2>/dev/null || true
          echo "✅ 复制了 $NEW_COUNT 个新字体"
        else
          echo "✅ 所有字体已存在，无需复制"
        fi

        echo "字体目录：$USER_FONT_DIR"
      '')
    ];

    # 3. 启用系统激活脚本，每次 rebuild 自动同步
    system.activationScripts.setupFlatpakFonts = {
      text = ''
        echo "🔄 设置 Flatpak 字体..."

        USER_HOME="/home/${targetUser}"
        USER_FONT_DIR="$USER_HOME/.local/share/fonts"

        if [ -d "$USER_HOME" ]; then
          mkdir -p "$USER_FONT_DIR"

          # 从系统字体目录复制
          for SOURCE_DIR in /nix/var/nix/profiles/system/sw/share/fonts; do
            if [ -d "$SOURCE_DIR" ]; then
              find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | \
                while read FONT; do
                  FONT_NAME=$(basename "$FONT")
                  if [ ! -f "$USER_FONT_DIR/$FONT_NAME" ]; then
                    cp -f "$FONT" "$USER_FONT_DIR/$FONT_NAME" 2>/dev/null || true
                  fi
                done
            fi
          done

          # 设置权限
          chown -R ${targetUser}:users "$USER_FONT_DIR" 2>/dev/null || true
          chmod 755 "$USER_FONT_DIR"

          # 更新字体缓存
          sudo -u ${targetUser} fc-cache -f "$USER_FONT_DIR" 2>/dev/null || true

          echo "✅ Flatpak 字体设置完成"
        else
          echo "  警告：用户 ${targetUser} 的主目录不存在，跳过"
        fi
      '';
      deps = [ "users" "groups" ];
    };

  };
}