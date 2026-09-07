# /etc/nixos/home/niri.nix
# Niri 用户级配置（Niri 分支，替代 cosmic.nix）
#
# 美化方案（社区公认方案，reddit/B站/YouTube 验证）:
#   - niri 26.04: 滚动平铺 + 背景模糊 (blur)
#   - DMS Shell: Material Design 3 一站式桌面 Shell（状态栏/启动器/通知/锁屏）
#   - matugen: 壁纸自动配色（换壁纸 → 全桌面主题自动跟随）
#   - Catppuccin Mocha: GTK 主题
#   - swaybg: 壁纸
#   - swaylock-effects: 锁屏（模糊特效）
#
# 官方文档:
#   niri 配置: https://niri-wm.github.io/niri/Configuration%3A-Introduction.html
#   DMS: https://danklinux.com
{
  pkgs,
  lib,
  ...
}:

{
  # ── Niri 桌面组件（Wayland 生态）────────────────────────────
  # 状态栏/启动器/通知/壁纸/配色/锁屏/截图
  home.packages = with pkgs; [
    fuzzel # 应用启动器
    # mako 已移除：DMS 接管通知（org.freedesktop.Notifications）
    swaybg # 壁纸
    matugen # 壁纸自动配色（Material You）
    # swaylock-effects/swayidle 已移除（DMS 自带锁屏+会话管理）
    wlogout # 关机菜单
    grim # 截图
    slurp # 区域选择
    wl-clipboard # 剪贴板（wl-copy/wl-paste）
    # 系统托盘图标支持（kdeconnect 托盘图标需要）
    libdbusmenu-gtk3
    # GTK 主题（Dolphin/Qt 应用美化——Material 风与 DMS 契合）
    colloid-gtk-theme
    # 音量控制（niri 快捷键用）
    playerctl
    # Wayland 剪贴板持久化（Klipper 等价物——应用关闭后剪贴板保持）
    wl-clip-persist
  ];

  # ── niri 窗口管理器（home-manager 声明式接管，替代手写 config.kdl）──
  wayland.windowManager.niri = {
    enable = true;
    # checkConfig: 生成后自动 niri validate（build 期暴露语法错误）

    # 声明式配置（settings → config.kdl，类型检查）
    settings = {
      # 输入设备
      input = {
        # niri Mod（Alt+右键 resize 窗口）= 物理 Alt（input 直属节点）
        "mod-key" = "Alt";
        keyboard.xkb = {
          layout = "us";
          options = "ctrl:nocaps";
        };
        touchpad = {
          tap = { };
          "natural-scroll" = { };
        };
        mouse = {
          "accel-profile" = "flat"; # 关闭鼠标加速（libinput 默认 adaptive 加速——用户对比 Win 明显）
        };
      };

      # ═══ 显示器：完全自动化（零写死）═══
      # 分辨率/刷新率由 niri-auto-output 脚本动态检测生成 output.kdl
      # （最高分辨率 + 最高刷新率 + VRR），换 4K 显示器自动适配
      # 见 extraConfig 的 include + systemd.services.niri-auto-output
      # 布局（DMS overview 需要透明 workspace 背景）
      layout = {
        gaps = 16;
        "background-color" = "transparent";
        "focus-ring" = {
          width = 2;
          "active-color" = "#cba6f7";
          "inactive-color" = "#45475a";
        };
        border = {
          width = 2;
          "active-color" = "#89b4fa";
          "inactive-color" = "#313244";
        };
        "default-column-width" = {
          proportion = 0.5;
        };
      };

      # ═══ 快捷键：全部由 DMS 设置中心管理（binds.kdl——官方路径）═══
      # config.kdl 不声明快捷键——只 include dms/binds.kdl（见 extraConfig）
      # 同步: sync-dms-settings.sh（cp binds.kdl → 仓库）+ activation 首次恢复
    };

    # 复杂/重复节点保持 KDL（window-rule ×5、spawn-at-startup ×4、include、layer-rule）
    extraConfig = ''
      // ═══ 自动显示器配置（niri-auto-output 脚本生成，最高分辨率+最高刷新率+VRR）═══
      include optional=true "output.kdl"
      // DMS 显示器设置（DMS 设置中心管理：VRR/分辨率/位置等）
      // 注: 在 output.kdl 之后 include → DMS 设置优先（自动检测为 fallback）
      include optional=true "dms/outputs.kdl"

      // ═══ DMS 集成分片（DMS 设置中心写入 ~/.config/niri/dms/*.kdl）═══
      // 预置 include → DMS 检测到已包含 → 只写可写分片（不尝试改只读 config.kdl）
      // 修复: DMS 键盘快捷键/窗口规则等设置无法保存（Fix failed）
      include optional=true "dms/binds.kdl"
      include optional=true "dms/cursor.kdl"
      include optional=true "dms/colors.kdl"
      include optional=true "dms/input.kdl"
      include optional=true "dms/alttab.kdl"
      include optional=true "dms/layout.kdl"
      include optional=true "dms/windowrules.kdl"
      include optional=true "dms/wpblur.kdl"

      // background blur for all windows (niri 26.04 feature)
      window-rule {
          match app-id=r#"^.*$"#
          background-effect {
              blur true
          }
      }

      // ═══ 窗口规则：全部由 DMS 设置中心管理（windowrules.kdl）═══
      // 默认平铺；单窗口规则（浮动/尺寸/无模糊/透明度）→ DMS UI 设置
      // 同步: sync-dms-settings.sh + activation 首次恢复（换机）

      // 基础服务（DMS shell 由 dms.service 启动，见 programs.dank-material-shell）
      // spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      // fcitx5 已由 i18n.inputMethod 的 XDG autostart 启动——此处不重复
      // （之前双实例: "Failed to create addon: dbus ... another fcitx already running"）
      spawn-at-startup "kdeconnect-indicator"
      // 剪贴板持久化（wl-clip-persist——应用关闭后 Ctrl+V 仍有效）
      spawn-at-startup "wl-clip-persist" "--clipboard" "regular"
      // PolicyKit 授权弹窗：由 DMS 自带 agent 处理（样式统一）
      // （移除了 polkit-kde-agent——避免与 DMS agent 冲突 "already exists"）
    '';
  };

  # ── DXVK 全局配置（声明式，替代手工 ~/.config/dxvk.conf）──
  # 作用: 强制 DXVK 不内建 vsync，防止 niri 双重锁帧（50fps 问题兜底）
  home.file.".config/dxvk.conf".text = ''
    # DXVK 全局配置：关闭内建 vsync
    # 解决 niri 下双重 vsync（DXVK FIFO + 合成器）导致的 50fps 锁帧
    # 由 niri 合成器统一 vsync（VRR 自适应）
    dxgi.syncInterval = 0
  '';

  # ── 壁纸 (通过 matugen 自动配色) ────────────────────────────
  # 注意: 壁纸是静态资源，路径可跨机器；新 PC 需替换此文件。
  # 放置: home/wallpaper.jpg（用户可随时更换，换后运行 matugen 重新配色）

  # ── Fuzzel 启动器 (Catppuccin Mocha) ────────────────────────
  xdg.configFile."fuzzel/fuzzel.ini" = {
    text = ''
      [main]
      font=LXGW WenKai Screen 14
      terminal=ghostty-ime
      prompt="❯ "

      [colors]
      background=1e1e2eee
      text=cdd6f4ff
      prompt=cba6f7ff
      input=cdd6f4ff
      match=89b4faff
      selection=313244ff
      selection-text=cdd6f4ff
      border=cba6f7ff

      [border]
      width=2
      radius=12
    '';
    force = true;
  };

  # ── GTK 主题（Qt 应用通过 QT_QPA_PLATFORMTHEME=gtk3 读取）──
  # DMS 图标/主题依赖 GTK 设置
  gtk = {
    enable = true;
    # Colloid-Dark: Material 风（与 DMS 契合），替代默认 Adwaita
    # Dolphin 等 Qt 应用通过 QT_QPA_PLATFORMTHEME=gtk3 读取
    theme.name = "Colloid-Dark";
    iconTheme.name = "Papirus";
    font.name = "LXGW WenKai Screen";
    font.size = 10;
    gtk3.extraConfig = {
      gtk-cursor-theme-name = "Nordzy-catppuccin-mocha-dark";
    };
    gtk4.extraConfig = {
      gtk-cursor-theme-name = "Nordzy-catppuccin-mocha-dark";
    };
  };

  # ── DMS 壁纸初始化（登录壁纸跟随桌面）──────────────────────
  # DMS 桌面换壁纸 → 写 ~/.local/state/DankMaterialShell/session.json
  # DMS greeter 读同一文件 → 登录壁纸自动同步（原生机制，无需桥接）
  # 此处仅初始化默认壁纸（首次登录时生效）
  home.activation.syncDmsWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # 仅首次初始化（session.json 不存在时）——DMS 换壁纸后不再被覆盖
    if [ ! -f ~/.local/state/DankMaterialShell/session.json ]; then
    mkdir -p ~/.local/state/DankMaterialShell
    WALLPAPER="/home/zhangchongjie/Pictures/background/wallhaven-l36xyy.png"
    cat > ~/.local/state/DankMaterialShell/session.json <<JSON
    {
      "wallpaperPath": "$WALLPAPER",
      "perMonitorWallpaper": false,
      "monitorWallpapers": {},
      "perModeWallpaper": false,
      "wallpaperPathLight": "",
      "wallpaperPathDark": "",
      "monitorWallpapersLight": {},
      "monitorWallpapersDark": {},
      "monitorWallpaperFillModes": {},
      "wallpaperFillMode": "Fit",
      "wallpaperTransition": "fade",
      "includedTransitions": ["none", "fade", "wipe", "disc", "stripes", "iris bloom", "pixelate", "portal"],
      "wallpaperCyclingEnabled": false,
      "wallpaperCyclingMode": "interval",
      "wallpaperCyclingInterval": 300,
      "wallpaperCyclingTime": "06:00",
      "monitorCyclingSettings": {},
      "nightModeEnabled": false,
      "nightModeTemperature": 4500,
      "nightModeHighTemperature": 6500,
      "nightModeLowTemperature": 4000
    }
    JSON
    fi
  '';

  # DMS 配置已由 HM 完整声明（见 dms.nix 的 home.file settings.json）

  # ── DMS 配置首次恢复（换机）──
  # binds.kdl/windowrules.kdl 是 DMS 设置中心管理的用户文件——不部署（只读锁会阻止 DMS 写）
  # 换机: 仓库 dms-shell/ → 用户目录（仅首次/文件不存在——不覆盖 DMS 改动）
  home.activation.restoreDmsConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/.config/niri/dms"
    for f in binds.kdl windowrules.kdl; do
      if [ ! -f "$HOME/.config/niri/dms/$f" ]; then
        cp ${./dms-shell}/$f "$HOME/.config/niri/dms/$f"
        echo "restoreDmsConfig: 已恢复 $f"
      fi
    done
  '';

  # ── 自启动 systemd 服务 ────────────────────────────────────
  systemd.user.services = {
    # 自动检测显示器 → 生成 output.kdl（最高分辨率+最高刷新率+VRR）
    # 换显示器/4K → 重跑: systemctl --user restart niri-auto-output
    niri-auto-output = {
      Unit = {
        Description = "Auto-detect monitors and generate niri output.kdl";
        After = [ "niri.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash ${./scripts/niri-auto-output.sh}";
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };
  };
}
