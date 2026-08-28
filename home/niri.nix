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
{ pkgs, lib, ... }:

let
  # Clavis 打包（与系统模块共用同一份源码）
  clavis = import ../modules/services/clavis/package.nix {
    inherit (pkgs)
      lib
      stdenv
      cmake
      ninja
      pkg-config
      git
      patchelf
      python3
      fetchFromGitHub
      wrapQtAppsHook
      ;
    qt6Packages = pkgs.qt6Packages;
    inherit (pkgs)
      quickshell
      pipewire
      libcava
      ncurses
      fftw
      ;
  };
in
{
  # ── Niri 桌面组件（Wayland 生态）────────────────────────────
  # 状态栏/启动器/通知/壁纸/配色/锁屏/截图
  home.packages = with pkgs; [
    waybar # 状态栏（Catppuccin 渐变）
    fuzzel # 应用启动器
    # mako 已移除：Clavis 接管通知（org.freedesktop.Notifications），避免 D-Bus 冲突
    swaybg # 壁纸
    matugen # 壁纸自动配色（Material You）
    swaylock-effects # 锁屏（模糊特效）
    swayidle # 闲置管理
    wlogout # 关机菜单
    grim # 截图
    slurp # 区域选择
    wl-clipboard # 剪贴板（wl-copy/wl-paste）
    # 系统托盘图标支持（kdeconnect 托盘图标需要）
    libdbusmenu-gtk3
    # 音量控制（niri 快捷键用）
    playerctl
  ];

  # ── niri 配置文件 (KDL 格式) ────────────────────────────────
  # niri 官方配置路径: ~/.config/niri/config.kdl
  xdg.configFile."niri/config.kdl".text = ''
        // Niri config (KDL)
        // Beauty: gradient border + rounded corners + background blur + Catppuccin Mocha

        // Clavis 集成分片（Clavis 设置中心写入 ~/.config/niri/clavis/*.kdl）
        // 必须预置 include，否则 Clavis 因 config.kdl 只读报"权限不够"
        include optional=true "clavis/effects.kdl"
        include optional=true "clavis/cursor.kdl"
        include optional=true "clavis/colors.kdl"
        include optional=true "clavis/wallpaper.kdl"

        input {
                    keyboard {
                        xkb {
                            layout "us"
                            options "ctrl:nocaps"
                        }
                    }
                    touchpad {
                        tap
                        natural-scroll
                    }
                    mouse {
                    }
                }

                output "PHL 325E1" {
                    mode "2560x1440@75.000"
                }

    layout {
        gaps 16
        // Clavis overview 背景需要透明 workspace 背景
        // （backdrop 与窗口透明/模糊共存的必要条件，Clavis 文档 wallpaper-backends.md）
        background-color "transparent"
        focus-ring {
                        width 2
                        active-color "#cba6f7"
                        inactive-color "#45475a"
                    }
                    border {
                        width 2
                        active-color "#89b4fa"
                        inactive-color "#313244"
                    }
                    default-column-width { proportion 0.5; }
                }

                // Clavis overview 壁纸层（放 backdrop 后面，Clavis 文档 wallpaper-backends.md）
                layer-rule {
                    match namespace="^clavis-overview-wallpaper$"
                    place-within-backdrop true
                }

                // background blur for all windows (niri 26.04 feature)
                window-rule {
                    match app-id=r#"^.*$"#
                    background-effect {
                        blur true
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

                // 所有窗口默认浮动（含以后新装的）——KDE/COSMIC 式堆叠窗口
                // niri 是平铺合成器，但 open-floating 让所有窗口按浮动布局打开：
                // 可自由拖动（按住窗口移动）、调整大小（拖边缘）、堆叠
                window-rule {
                    match app-id=r#"^.*$"#
                    open-floating true
                }

                binds {
                    Mod+Return hotkey-overlay-title="Open Terminal" { spawn "ghostty-ime"; }
                    Mod+D hotkey-overlay-title="Run Application" { spawn "fuzzel"; }
                    Mod+B hotkey-overlay-title="Open Browser" { spawn "floorp"; }
                    Mod+Q { close-window; }
                    Mod+F { maximize-column; }
                    Mod+Shift+F { fullscreen-window; }
                    Mod+V { toggle-window-floating; }
                    Mod+L hotkey-overlay-title="Lock Screen" { spawn "swaylock"; }
                    Mod+P hotkey-overlay-title="Power Menu" { spawn "wlogout"; }
                    Print { spawn "grim" "-g" "$(slurp)" "-" "|" "wl-copy"; }

                    Mod+H { focus-column-left; }
                    Mod+J { focus-column-right; }
                    Mod+Shift+H { move-column-left; }
                    Mod+Shift+J { move-column-right; }

                    Mod+1 { focus-workspace 1; }
                    Mod+2 { focus-workspace 2; }
                    Mod+3 { focus-workspace 3; }
                    Mod+4 { focus-workspace 4; }
                    Mod+Shift+1 { move-column-to-workspace 1; }
                    Mod+Shift+2 { move-column-to-workspace 2; }
                    Mod+Shift+3 { move-column-to-workspace 3; }
                    Mod+Shift+4 { move-column-to-workspace 4; }

                    Mod+E { quit; }
                }

            spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
            // Clavis shell 由 clavis-shell.service 启动（systemd user unit），
            // 这里只启动基础服务
            spawn-at-startup "fcitx5" "-d"
            spawn-at-startup "kdeconnect-indicator"
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

  # ── swaylock-effects 锁屏 (模糊特效) ─────────────────────────
  xdg.configFile."swaylock/config" = {
    text = ''
      ignore-empty-password
      screenshot
      effect-blur=10x5
      color=1e1e2e
      ring-color=cba6f7
      key-hl-color=89b4fa
      line-color=00000000
      inside-color=00000000
      separator-color=00000000
      text-color=cdd6f4
      font=LXGW WenKai Screen
      font-size=24
    '';
    force = true;
  };
  # ── Clavis 配置目录（quickshell 用户配置）───────────────────
  # 指向 /etc/nixos 仓库中的 Clavis 源码（声明式管理）
  xdg.configFile."quickshell/clavis".source = ../modules/services/clavis/clavis-shell;

  # ── DMS greeter 壁纸同步（登录壁纸跟随桌面）────────────────
  # DMS greeter 读 ~/.local/state/DankMaterialShell/session.json
  # 方案: 启动脚本生成可写 session.json（初始 = 当前 Clavis 壁纸）
  #       + systemd path unit 监控 Clavis config.json → 换壁纸自动同步
  # ⚠️ 不用 xdg.stateFile（符号链接只读，无法被脚本更新）
  home.activation.syncDmsWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ~/.local/state/DankMaterialShell
    # 从 Clavis config 读当前壁纸
    WALLPAPER="$(jq -r '.wallpaper.path // empty' ~/.config/clavis/config.json 2>/dev/null || echo "")"
    if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
      WALLPAPER="/home/zhangchongjie/Pictures/background/wallhaven-l36xyy.png"
    fi
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
  '';

  # DMS greeter 设置（指纹优先）
  # greeterEnableFprint: true → DMS UI 先等待指纹，失败才 fallback 密码
  home.activation.syncDmsSettings = lib.hm.dag.entryAfter [ "syncDmsWallpaper" ] ''
    mkdir -p ~/.config/DankMaterialShell
    cat > ~/.config/DankMaterialShell/settings.json <<JSON
    {
      "greeterEnableFprint": true,
      "greeterEnableU2f": false,
      "greeterRememberLastUser": true
    }
    JSON
  '';

  # ── 自启动 systemd 服务 ────────────────────────────────────
  systemd.user.services = {
    # Clavis Shell（桌面 shell 主进程）
    clavis-shell = {
      Unit = {
        Description = "Clavis Shell";
        Requisite = [ "niri.service" ];
        PartOf = [ "niri.service" ];
        After = [ "niri.service" ];
      };
      Service = {
        Type = "simple";
        # QML_IMPORT_PATH: Clavis native 插件 + Qt5Compat 毛玻璃 + Lottie 天气动画
        Environment = "QML_IMPORT_PATH=${clavis.clavis-shell}/lib/qt6/qml:${pkgs.qt6Packages.qt5compat}/lib/qt-6/qml:${pkgs.qt6Packages.qtlottie}/lib/qt-6/qml";
        ExecStart = "${clavis.key-cli}/bin/key shell --foreground --no-duplicate";
        Restart = "on-failure";
        RestartSec = "2";
      };
      Install = {
        WantedBy = [ "niri.service" ];
      };
    };
    # swayidle: 闲置锁屏
    swayidle = {
      Unit = {
        Description = "Sway idle manager";
        After = [ "graphical-session.target" ];
      };
      Service = {
        # 注意: ExecStart 必须是单行（systemd 不支持续行）
        ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 '${pkgs.swaylock-effects}/bin/swaylock -f' timeout 900 '${pkgs.swaybg}/bin/swaybg' before-sleep '${pkgs.swaylock-effects}/bin/swaylock -f'";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };

  # ── 壁纸同步监控（Clavis 换壁纸 → 更新 DMS 登录壁纸）──────
  systemd.user.paths."sync-dms-wallpaper" = {
    Unit = {
      Description = "Monitor Clavis wallpaper changes";
      After = [ "graphical-session.target" ];
    };
    Path = {
      # 监控 Clavis 壁纸配置变化
      PathChanged = "%h/.config/clavis/config.json";
      MakeDirectory = true;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  # 同步服务（path 触发执行）
  systemd.user.services."sync-dms-wallpaper" = {
    Unit = {
      Description = "Sync DMS greeter wallpaper from Clavis";
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash -c 'W=\$(jq -r \".wallpaper.path // empty\" ~/.config/clavis/config.json 2>/dev/null || echo \"\"); if [ -n \"\$W\" ] && [ -f \"\$W\" ]; then jq --arg w \"\$W\" \".wallpaperPath = \\\$w\" ~/.local/state/DankMaterialShell/session.json > /tmp/session.tmp && mv /tmp/session.tmp ~/.local/state/DankMaterialShell/session.json; fi'";
    };
  };
}
