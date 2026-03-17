{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.flatpak-fonts;
in
{
  options.services.flatpak-fonts = {
    # enable = mkEnableOption (mdDoc "自动复制系统字体到用户目录供Flatpak使用");
    enable = mkEnableOption "...";
    userName = mkOption {
      type = types.str;
      default = "";
      description = "目标用户名，留空则对所有用户生效";
    };
  };

  config = mkIf cfg.enable {
    # 1. 首先确保安装了必要的字体包
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        dejavu_fonts
        lxgw-wenkai-screen
        lxgw-wenkai
      ];
    };

    # 2. 创建同步脚本
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "sync-flatpak-fonts" ''
        #!/usr/bin/env bash
        set -e

        USER_HOME="/home/${username}"
        USER_FONT_DIR="$USER_HOME/.local/share/fonts"

        if [ ! -d "$USER_HOME" ]; then
          echo "错误: 用户 ${username} 的主目录不存在"
          exit 1
        fi

        echo "🔤 为用户 ${username} 设置 Flatpak 字体..."

        # 确保目录存在
        mkdir -p "$USER_FONT_DIR"

        # 计数器
        NEW_FONT_COUNT=0
        EXISTING_FONT_COUNT=0

        # 定义字体格式扩展名
        FONT_EXTENSIONS=("ttf" "ttc" "otf")

        # 函数：检查文件是否已存在
        font_exists() {
          local font_path="$1"
          local font_name="$(basename "$font_path")"

          # 检查所有可能的字体扩展名
          for ext in "''${FONT_EXTENSIONS[@]}"; do
            if [ -f "$USER_FONT_DIR/$font_name" ] || [ -f "$USER_FONT_DIR/''${font_name%.*}.$ext" ]; then
              return 0
            fi
          done
          return 1
        }

        # 函数：复制字体文件
        copy_font() {
          local font_path="$1"
          local font_name="$(basename "$font_path")"
          local dest_path="$USER_FONT_DIR/$font_name"

          # 检查文件是否已存在
          if font_exists "$font_path"; then
            echo "    ⏭️  跳过已存在: $font_name"
            ((EXISTING_FONT_COUNT++))
            return 0
          fi

          # 检查文件大小和类型
          if [ -f "$font_path" ] && [ -s "$font_path" ]; then
            # 确保是有效的字体文件
            if file "$font_path" | grep -qi "font\|TrueType\|OpenType"; then
              cp -f "$font_path" "$dest_path" 2>/dev/null
              if [ $? -eq 0 ]; then
                echo "    ✓ 复制: $font_name"
                ((NEW_FONT_COUNT++))
                return 0
              else
                echo "    ✗ 复制失败: $font_name"
                return 1
              fi
            else
              echo "    ⚠️  忽略非字体文件: $font_name"
              return 0
            fi
          fi
          return 1
        }

        echo "收集系统中安装的字体..."

        # 从字体包中查找字体文件
        for font_pkg in ${pkgs.wqy_zenhei} ${pkgs.wqy_microhei} ${pkgs.noto-fonts} ${pkgs.dejavu_fonts} ${pkgs.lxgw-wenkai-screen} ${pkgs.lxgw-wenkai}; do
          if [ -d "$font_pkg" ]; then
            echo "  搜索字体包: $(basename "$font_pkg")"
            find "$font_pkg" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | \
              while read -r FONT; do
                copy_font "$FONT"
              done
          fi
        done

        # 从系统字体目录查找
        SYSTEM_FONT_DIRS="/nix/var/nix/profiles/system/sw/share/X11/fonts /nix/var/nix/profiles/system/sw/share/fonts"

        for SOURCE_DIR in $SYSTEM_FONT_DIRS; do
          if [ -d "$SOURCE_DIR" ]; then
            echo "  从 $SOURCE_DIR 搜索字体..."
            find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | \
              while read -r FONT; do
                copy_font "$FONT"
              done
          fi
        done

        # 统计结果
        if [ "$NEW_FONT_COUNT" -gt 0 ]; then
          echo "  更新字体缓存..."
          fc-cache -f "$USER_FONT_DIR"
          echo "✅ 复制了 $NEW_FONT_COUNT 个新字体，跳过了 $EXISTING_FONT_COUNT 个已存在字体"
        elif [ "$EXISTING_FONT_COUNT" -gt 0 ]; then
          echo "✅ 所有 $EXISTING_FONT_COUNT 个字体已存在，无需复制"
        else
          echo "⚠️  警告: 没有找到任何字体文件"
        fi

        echo "字体目录: $USER_FONT_DIR"
      '')
    ];

    # 3. 系统激活脚本
    # system.activationScripts.setupFlatpakFonts = {
    #   text = ''
    #     echo "🔄 设置 Flatpak 字体..."

    #     USER_HOME="/home/${username}"
    #     USER_FONT_DIR="$USER_HOME/.local/share/fonts"

    #     if [ -d "$USER_HOME" ]; then
    #       echo "  为用户 ${username} 复制字体..."

    #       # 创建字体目录
    #       mkdir -p "$USER_FONT_DIR"

    #       # 计数器
    #       NEW_FONT_COUNT=0
    #       EXISTING_FONT_COUNT=0

    #       # 函数：检查文件是否已存在
    #       font_exists() {
    #         local font_path="$1"
    #         local font_name="$(basename "$font_path")"

    #         # 检查文件是否存在
    #         [ -f "$USER_FONT_DIR/$font_name" ] && return 0

    #         # 检查是否有相同字体文件但不同扩展名的情况
    #         local base_name="''${font_name%.*}"
    #         [ -f "$USER_FONT_DIR/''${base_name}.ttf" ] && return 0
    #         [ -f "$USER_FONT_DIR/''${base_name}.ttc" ] && return 0
    #         [ -f "$USER_FONT_DIR/''${base_name}.otf" ] && return 0

    #         return 1
    #       }

    #       echo "  从字体包复制字体..."

    #       # 直接从字体包复制字体
    #       copy_fonts_from_package() {
    #         local pkg_path="$1"
    #         local pkg_name="$2"

    #         if [ -d "$pkg_path" ]; then
    #           echo "    处理: $pkg_name"
    #           find "$pkg_path" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | \
    #             while read FONT; do
    #               FONT_NAME=$(basename "$FONT")
    #               if font_exists "$FONT"; then
    #                 echo "      ⏭️ 跳过已存在: $FONT_NAME"
    #                 EXISTING_FONT_COUNT=$((EXISTING_FONT_COUNT + 1))
    #                 continue
    #               fi

    #               if cp -f "$FONT" "$USER_FONT_DIR/$FONT_NAME" 2>/dev/null; then
    #                 echo "      ✓ 复制: $FONT_NAME"
    #                 NEW_FONT_COUNT=$((NEW_FONT_COUNT + 1))
    #               fi
    #             done
    #         fi
    #       }

    #       # Noto字体
    #       copy_fonts_from_package "${pkgs.noto-fonts}" "Noto字体"

    #       # DejaVu字体
    #       copy_fonts_from_package "${pkgs.dejavu_fonts}" "DejaVu字体"

    #       # 霞鹜文楷
    #       copy_fonts_from_package "${pkgs.lxgw-wenkai}" "霞鹜文楷"

    #       # 霞鹜文楷屏幕版
    #       copy_fonts_from_package "${pkgs.lxgw-wenkai-screen}" "霞鹜文楷屏幕版"

    #       # 更改所有权
    #       chown -R ${username}:users "$USER_FONT_DIR"
    #       chmod 755 "$USER_FONT_DIR"

    #       # 统计字体数量
    #       TOTAL_FONT_COUNT=$(find "$USER_FONT_DIR" -type f \( -name "*.ttf" -o -name "*.ttc" -o -name "*.otf" \) 2>/dev/null | wc -l)

    #       if [ "$NEW_FONT_COUNT" -gt 0 ]; then
    #         echo "    创建字体缓存..."
    #         sudo -u ${username} fc-cache -f "$USER_FONT_DIR" 2>/dev/null || true
    #         echo "    复制了 $NEW_FONT_COUNT 个新字体，跳过了 $EXISTING_FONT_COUNT 个已存在字体"
    #       elif [ "$EXISTING_FONT_COUNT" -gt 0 ]; then
    #         echo "    所有 $EXISTING_FONT_COUNT 个字体已存在，无需复制"
    #       fi

    #       echo "    总计 $TOTAL_FONT_COUNT 个字体文件在: $USER_FONT_DIR"
    #     else
    #       echo "  警告: 用户 ${username} 的主目录不存在，跳过"
    #     fi

    #     echo "✅ Flatpak 字体设置完成"
    #   '';
    #   deps = [ "users" "groups" ];
    # };
  };
}
