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
  # 文件选择器：nautilus 的 portal 集成保留（Dolphin 作为默认文件管理器）
  # note: niri 的 useNautilus 只是 portal 文件选择器，不影响默认文件管理器
  programs.niri.useNautilus = true;

  # 默认文件管理器 = dolphin（KDE，侧边栏设备/硬盘挂载最强）
  # nautilus 侧边栏不显示未挂载硬盘，换成 dolphin 可右键挂载 NTFS 等
  xdg.mime.defaultApplications."inode/directory" = [ "org.kde.dolphin.desktop" ];
  xdg.mime.defaultApplications."x-scheme-handler/file" = [ "org.kde.dolphin.desktop" ];

  # ── DMS greeter 登录管理器（用户要求恢复）─────────────────
  # DMS (DankMaterialShell) greeter: quickshell 系，支持指纹交互
  # 与桌面 Clavis shell 同为 quickshell 生态，风格统一
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
    compositor.customConfig = "";
    # 同步用户 DMS 配置到登录界面（壁纸/主题跟随桌面）
    configHome = "/home/zhangchongjie";
  };

  # 默认会话 = niri
  services.displayManager.defaultSession = "niri";

  # dms-greeter PAM：只用指纹登录（一次验证）
  # 指纹 sufficient（通过即成功）；密码作为紧急 fallback（保留）
  # 说明: DMS greeter 是 quickshell 系，支持 fprintd 指纹交互
  #       指纹通过后直接登录，不再二次询问
  security.pam.services.dms-greeter = {
    # 指纹优先，失败才问密码（用户要求）
    # sufficient 链: fprintd (order 1) 成功→通过；失败→ unix (order 2) 密码
    rules.auth.fprintd.order = 1;
    rules.auth.unix.order = 2; # 密码 fallback（指纹失败时）
    # gnome-keyring 解锁（登录时自动解锁 keyring，避免桌面弹"unlock login keyring"）
    # 与 login PAM 一致：auth/password/session 都是 optional
    rules.auth.gnome_keyring = {
      order = 3;
      control = "optional";
      modulePath = "pam_gnome_keyring.so";
    };
    rules.password.gnome_keyring = {
      control = "optional";
      modulePath = "pam_gnome_keyring.so";
      args = [ "use_authtok" ];
    };
    rules.session.gnome_keyring = {
      control = "optional";
      modulePath = "pam_gnome_keyring.so";
      args = [ "auto_start" ];
    };
  };

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
    # Clavis 脚本依赖（补齐缺失命令，修复电源按钮/通知/音量等控件）
    gettext # envsubst（power-menu.sh 必需，电源按钮失效根因）
    libnotify # notify-send（通知）
    gnome-system-monitor # 系统监视器（Clavis 按钮）
    pavucontrol # 音量控制
    wlsunset # 夜间色温（Clavis 按键）
    # 文件管理器：dolphin（KDE，侧边栏设备/硬盘挂载最强，NTFS 右键挂载）
    kdePackages.dolphin
    ntfs3g # NTFS 挂载（内核 ntfs3 未注册时 fallback）
    satty # 截图编辑（替代 KDE Spectacle 的编辑功能，Wayland 原生）
    kdePackages.polkit-kde-agent-1 # PolicyKit GUI 授权弹窗（Dolphin 挂载硬盘需要）
    gnome-software # Flatpak 应用商店（libadwaita 风格，最接近 Clavis Material 3；管理 QQ/微信等 flatpak 应用）
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
    # Qt 走 GTK 主题（Clavis 读 GTK 图标主题；原版 dotfiles 用此值）
    # 缺失导致 qsimage 图标加载失败（通知图标/头像不显示）
    QT_QPA_PLATFORMTHEME = "gtk3";
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
