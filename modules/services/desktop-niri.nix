# /etc/nixos/modules/services/desktop-niri.nix
# Niri 桌面环境与显示管理 (Niri, DMS greeter, Fcitx5, XDG Portal)
# 分支: Niri —— 本文件替代 desktop-cosmic.nix
#
# 官方文档:
#   programs.niri: https://search.nixos.org/options?show=programs.niri.enable
#   dms-greeter: https://search.nixos.org/options?show=services.displayManager.dms-greeter.enable
#   i18n.inputMethod: https://search.nixos.org/options?show=i18n.inputMethod.enable
{ pkgs, lib, ... }:

let
  # Clavis Shell + key-cli + keytop 打包
  clavis = import ./clavis/package.nix {
    inherit lib;
    inherit (pkgs)
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
  # ── Fcitx5 输入法（保留，与 COSMIC 分支一致）────────────────────
  # niri 实现 zwp_input_method_v2；fcitx5 ≥ 5.1.12 支持该协议。
  # fcitx5 由 i18n.inputMethod 生成的 XDG autostart 条目自动启动，
  # niri 遵循 XDG autostart 规范。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      kdePackages.fcitx5-chinese-addons
      kdePackages.fcitx5-configtool
      fcitx5-material-color
    ];
  };

  # ── Niri 滚动平铺 Wayland 合成器 ─────────────────────────────
  programs.niri.enable = true;

  # ── greetd + nwg-hello 登录管理器（替代 DMS greeter）────────
  # nwg-hello: GTK3 密码框 greeter（Sugar Candy 风格），与 Clavis 暗色主题协调
  # 参考: https://github.com/nwg-piotr/nwg-hello
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # cage 是 Wayland 合成器，跑 nwg-hello greeter
        command = "${pkgs.cage} -s -- ${pkgs.nwg-hello}";
        user = "greeter";
      };
    };
  };

  # greeter 用户需要 video/render/input 组才能访问 DRM/GPU/输入设备
  # （NixOS 默认 greeter 无组 → cage 无法访问 /dev/dri → 登录界面崩溃）
  users.users.greeter = {
    isSystemUser = true;
    group = "greeter";
    extraGroups = [
      "video" # DRM 设备访问（cage 需要）
      "render" # GPU 渲染节点
      "input" # 输入设备（鼠标/键盘）
    ];
  };
  users.groups.greeter = { };

  # nwg-hello 配置（主题/会话）
  environment.etc."nwg-hello/nwg-hello.json".text = ''
    {
      "session_dirs": ["/run/current-system/sw/share/wayland-sessions"],
      "custom_sessions": [],
      "monitor_nums": [],
      "form_on_monitors": [],
      "delay_secs": 1,
      "cmd-sleep": "systemctl suspend",
      "cmd-reboot": "systemctl reboot",
      "cmd-poweroff": "systemctl poweroff",
      "gtk-theme": "Adwaita",
      "gtk-icon-theme": "Papirus",
      "gtk-cursor-theme": "Nordzy-catppuccin-mocha-dark",
      "prefer-dark-theme": true,
      "template-name": "",
      "time-format": "%H:%M",
      "date-format": "%A, %m月%d日",
      "layer": "overlay",
      "keyboard-mode": "on_demand",
      "lang": "zh_CN.UTF-8",
      "avatar-show": true,
      "avatar-size": 100,
      "avatar-border-width": 1,
      "avatar-border-color": "#cba6f7",
      "avatar-corner-radius": 15,
      "avatar-circle": false,
      "env-vars": ["XDG_CURRENT_DESKTOP=niri"]
    }
  '';

  # greetd PAM：登录界面只用密码（一次验证）
  # 说明: nwg-hello 是密码框 greeter，不支持指纹交互
  #       用 text 完全覆盖 greetd 的 PAM（greetd 模块默认 substack login 含 fprintd，
  #       会导致"输完密码还要指纹"的双重验证）
  #       系统内（锁屏/sudo/终端）指纹照常（由各自 PAM 栈提供）
  security.pam.services.greetd.text = ''
    # Account management.
    account required ${pkgs.pam}/lib/security/pam_unix.so

    # Authentication management.
    auth sufficient ${pkgs.pam}/lib/security/pam_unix.so likeauth try_first_pass
    auth required ${pkgs.pam}/lib/security/pam_deny.so

    # Password management.
    password sufficient ${pkgs.pam}/lib/security/pam_unix.so nullok

    # Session management.
    session required ${pkgs.pam}/lib/security/pam_env.so conffile=/etc/pam/environment readenv=0
    session required ${pkgs.pam}/lib/security/pam_unix.so
    session required ${pkgs.pam}/lib/security/pam_loginuid.so
    session optional ${pkgs.systemd}/lib/security/pam_systemd.so
    session required ${pkgs.pam}/lib/security/pam_limits.so conf=${pkgs.buildPackages.pam}/etc/security/limits.conf
  '';

  # 默认会话 = niri
  services.displayManager.defaultSession = "niri";

  # ── Clavis Shell（桌面 shell，替代 DMS shell）─────────────────
  # Clavis 是 quickshell 系全生态 shell（状态栏/启动器/控制中心/锁屏）
  # 由 key-cli 的 `key shell` 命令启动（clavis-shell.service）
  # 源码/打包: modules/services/clavis/
  environment.systemPackages = with pkgs; [
    clavis.clavis-shell
    clavis.key-cli
    clavis.keytop
    quickshell # 提供 qs 命令（Clavis 的 key shell 依赖它启动）
    # Clavis 运行时依赖（README docs/dependencies.md）
    cliphist # 剪贴板历史
    wl-clipboard # wl-copy/wl-paste
    slurp # 区域选择
    ffmpeg # 录屏 GIF 后处理
    gpu-screen-recorder # 屏幕录制
    pulseaudio # 仅提供 pactl 命令（Clavis 需要；不启用服务，系统用 PipeWire）
    matugen # Material 动态配色
    ddcutil # 显示器亮度控制（Clavis 亮度模块用）
    brightnessctl # 笔记本背光亮度（Clavis 亮度模块用）
    imagemagick # magick 命令（Clavis overview 壁纸缓存必需）
    glib # gsettings（Clavis 配色同步系统主题需要）
    nordzy-cursor-theme # Catppuccin Mocha 光标主题（niri 需要光标，之前缺失导致 WARN）
  ];

  # UPower（Clavis 电池/电源模块需要；之前被禁用）
  services.upower.enable = true;

  # Clavis 配置目录符号链接（quickshell 用户配置，指向仓库源码）
  # 注: 由 home/niri.nix 的 xdg.configFile 处理（此处不重复）

  # ── XDG 会话变量 ───────────────────────────────────────────
  environment.sessionVariables = {
    TZ = "Asia/Shanghai";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    DESKTOP_SESSION = "niri";
    NIXOS_OZONE_WL = "1"; # 强制 Electron 应用使用 Wayland
    # 光标主题（niri + GTK 应用用；Catppuccin Mocha 与 Clavis 契合）
    XCURSOR_THEME = "Nordzy-catppuccin-mocha-dark";
    XCURSOR_SIZE = "24";
    # Wayland 下 IM 模块留空（fcitx5 走 text-input-v3，不启用 XIM 桥接）
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
  };

  # ── XDG Portal - niri 环境 ─────────────────────────────────
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
    };
  };

  # ── D-Bus 配置（broker 以获得更好的 Portal 支持）─────────────
  services.dbus.enable = true;
  services.dbus.implementation = "broker";

  # dconf - GTK 配置后端
  programs.dconf.enable = true;

  # 打印服务（默认禁用，与 COSMIC 分支一致）
  services.printing.enable = false;
}
