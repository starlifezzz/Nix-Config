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
    waybar # 状态栏（Catppuccin 渐变）
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
  ];

  # ── niri 窗口管理器（home-manager 声明式接管，替代手写 config.kdl）──
  wayland.windowManager.niri = {
    enable = true;
    # checkConfig: 生成后自动 niri validate（build 期暴露语法错误）

    # 声明式配置（settings → config.kdl，类型检查）
    settings = {
      # 输入设备
      input = {
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

      # 快捷键（声明式结构化）
      binds = {
        "Alt+Return" = {
          _props."hotkey-overlay-title" = "Open Terminal";
          spawn = [ "ghostty-ime" ];
        };
        "Alt+D" = {
          _props."hotkey-overlay-title" = "Run Application";
          spawn = [
            "key"
            "ipc"
            "call"
            "spotlight"
            "toggle"
          ];
        };
        "Alt+B" = {
          _props."hotkey-overlay-title" = "Open Browser";
          spawn = [ "floorp" ];
        };
        "Alt+Q" = {
          close-window = { };
        };
        "Alt+F" = {
          maximize-column = { };
        };
        "Alt+Shift+F" = {
          fullscreen-window = { };
        };
        # 外接显示器亮度（DMS 控制中心不含 DDC——用命令行步进）
        "Alt+Shift+Up" = {
          _props."hotkey-overlay-title" = "Brightness Up";
          "spawn-sh" = "${pkgs.bash}/bin/bash ${./scripts/brightness-step.sh} up";
        };
        "Alt+Shift+Down" = {
          _props."hotkey-overlay-title" = "Brightness Down";
          "spawn-sh" = "${pkgs.bash}/bin/bash ${./scripts/brightness-step.sh} down";
        };
        "Alt+V" = {
          _props."hotkey-overlay-title" = "Toggle Floating";
          "toggle-window-floating" = { };
        };
        "Alt+L" = {
          _props."hotkey-overlay-title" = "Lock Screen";
          spawn = [
            "dms"
            "ipc"
            "call"
            "lock"
          ];
        };
        "Alt+P" = {
          _props."hotkey-overlay-title" = "Power Menu";
          spawn = [ "wlogout" ];
        };
        "Alt+M" = {
          _props."hotkey-overlay-title" = "Open Dashboard";
          spawn = [
            "key"
            "ipc"
            "call"
            "keystone"
            "dashboard"
          ];
        };
        "Alt+Shift+W" = {
          _props."hotkey-overlay-title" = "Open Hub";
          spawn = [
            "key"
            "ipc"
            "call"
            "keystone"
            "hub"
          ];
        };
        "Ctrl+Alt+A" = {
          _props."hotkey-overlay-title" = "Screenshot Region";
          "spawn-sh" =
            "grim -g \"$(slurp)\" - | satty --filename - --output-filename /tmp/screenshot.png; wl-copy < /tmp/screenshot.png";
        };
        # Mod+E 打开文件管理器（DMS 设置中心添加——声明到 HM，换 PC 自动同步）
        "Mod+E" = {
          _props."hotkey-overlay-title" = "启动文件管理器";
          spawn = [ "nautilus" ];
        };
        "Alt+Shift+C" = {
          _props."hotkey-overlay-title" = "Clipboard History";
          spawn = [
            "dms"
            "ipc"
            "call"
            "clipboard"
            "toggle"
          ];
        };
        "Alt+H" = {
          focus-column-left = { };
        };
        "Alt+J" = {
          focus-column-right = { };
        };
        "Alt+Shift+H" = {
          move-column-left = { };
        };
        "Alt+Shift+J" = {
          move-column-right = { };
        };
        "Alt+1" = {
          focus-workspace = 1;
        };
        "Alt+2" = {
          focus-workspace = 2;
        };
        "Alt+3" = {
          focus-workspace = 3;
        };
        "Alt+4" = {
          focus-workspace = 4;
        };
        "Alt+Shift+1" = {
          "move-column-to-workspace" = 1;
        };
        "Alt+Shift+2" = {
          "move-column-to-workspace" = 2;
        };
        "Alt+Shift+3" = {
          "move-column-to-workspace" = 3;
        };
        "Alt+Shift+4" = {
          "move-column-to-workspace" = 4;
        };
        "Alt+E" = {
          quit = { };
        };
      };
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
      include optional=true "dms/binds-user.kdl"
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

      // ═══ 游戏窗口排除背景模糊（性能关键）═══
      // 全局 blur 会让全屏游戏每帧被高斯模糊 → GPU 占用暴增（75帧→50帧）
      // 实测: Steam/Proton 游戏 app-id = "steam_app_default"（RE2 实测确认）
      window-rule {
          match app-id=r#"(?i)(^re2$|^re[0-9]$|resident|wine|proton|dxvk|^gamescope$|steam_app_default)"#
          background-effect {
              blur false
          }
      }

      // rounded corners for all windows
      window-rule {
          match app-id=r#"^.*$"#
          geometry-corner-radius 12
          clip-to-geometry true
      }

      // terminal semi-transparent
      window-rule {
          match app-id=r#"^ghostty|^com\.mitchellh\.ghostty$"#
          opacity 0.9
      }

      // ═══ 默认浮动（KDE/COSMIC 式堆叠）═══
      // 用户反馈平铺难用 → 恢复全局浮动
      // 单窗口切换: Alt+V（toggle-window-floating）
      window-rule {
          match app-id=r#"^.*$"#
          open-floating true
      }

      // ═══ 窗口模式（平铺/浮动）═══
      // DMS 支持窗口管理集成；如有需要 DMS 设置中心管理

      // 基础服务（DMS shell 由 dms.service 启动，见 programs.dank-material-shell）
      // spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      // fcitx5 已由 i18n.inputMethod 的 XDG autostart 启动——此处不重复
      // （之前双实例: "Failed to create addon: dbus ... another fcitx already running"）
      spawn-at-startup "kdeconnect-indicator"
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

  # ── Waybar 状态栏 (Catppuccin Mocha 渐变) ───────────────────
  xdg.configFile."waybar/config" = {
    text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 32,
        "modules-left": ["hyprland/workspaces"],
        "modules-center": ["clock"],
        "modules-right": ["network", "pulseaudio", "cpu", "memory", "tray"],
        "hyprland/workspaces": {
          "format": "{name}",
          "active-only": false
        },
        "clock": {
          "format": " {:%H:%M}",
          "format-alt": " {:%Y-%m-%d}"
        },
        "network": {
          "format-wifi": " {essid}",
          "format-ethernet": " {ifname}",
          "format-disconnected": "⚠️"
        },
        "pulseaudio": {
          "format": " {volume}%"
        },
        "cpu": {
          "format": " {usage}%"
        },
        "memory": {
          "format": " {}%"
        },
        "tray": {
          "spacing": 8
        }
      }
    '';
    force = true;
  };

  xdg.configFile."waybar/style.css" = {
    text = ''
      * {
        font-family: "LXGW WenKai Screen", "Font Awesome 6 Free";
        font-size: 13px;
      }

      window#waybar {
        background: rgba(30, 30, 46, 0.85);
        color: #cdd6f4;
        border-bottom: 1px solid #313244;
      }

      #workspaces button {
        padding: 0 8px;
        color: #cdd6f4;
        background: transparent;
        border-radius: 8px;
      }

      #workspaces button.active {
        background: #cba6f7;
        color: #1e1e2e;
        border-radius: 8px;
      }

      #clock, #network, #pulseaudio, #cpu, #memory {
        padding: 0 10px;
        color: #cdd6f4;
        background: transparent;
      }

      #network {
        color: #89b4fa;
      }

      #pulseaudio {
        color: #a6e3a1;
      }

      #cpu {
        color: #f9e2af;
      }

      #memory {
        color: #f38ba8;
      }

      #tray {
        padding: 0 10px;
      }

      #tray menu {
        background: #1e1e2e;
        color: #cdd6f4;
      }
    '';
    force = true;
  };

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

  # ── systemd path 监听（DMS 快捷键自动同步）───────────────
  systemd.user.paths."sync-dms-binds" = {
    Unit = {
      Description = "Watch DMS keybinds file";
      After = [ "graphical-session.target" ];
    };
    Path = {
      # 监听 DMS 快捷键变化（设置中心加/减即触发）
      PathChanged = "%h/.config/niri/dms/binds.kdl";
      MakeDirectory = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
    # 监听 DMS 快捷键变化 → 自动同步到仓库（binds.kdl → dms-binds.kdl）
    # DMS 设置中心加/减快捷键 → path 触发 → 自动备份（换 PC 可恢复）
    sync-dms-binds = {
      Unit = {
        Description = "Sync DMS keybinds to repo";
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'cp %h/.config/niri/dms/binds.kdl /etc/nixos/home/dms-binds.kdl'";
      };
    };
  };

}
