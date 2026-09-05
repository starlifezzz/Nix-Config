# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    # ✅ 硬件配置文件（包含文件系统和 BTRFS 配置）
    # 此文件不会被 Git 追踪，每台设备可以有自己的配置
    ./hardware-configuration.nix

    # ✅ CPU 和 GPU 配置文件
    # 修改这里来切换硬件配置
    ./modules/hardware/cpu/ryzen-5600.nix # 可选：ryzen-1600x, ryzen-2600, ryzen-3600, ryzen-5600
    ./modules/hardware/gpu/rx-6600xt.nix # 可选：r9-370, rx-5500xt, rx-6600xt

    # ✅ 内核与启动参数模块
    ./modules/kernel/default.nix

    # ✅ 功能模块
    ./modules/network/default.nix # 网络基础设施(防火墙、DNS、Avahi)
    ./modules/network/wifi-bluetooth.nix # WiFi 和蓝牙配置
    ./modules/fonts/default.nix

    # ✅ SSD 存储优化模块
    ./modules/storage/ssd.nix

    # ✅ 系统服务模块
    ./modules/services/audio.nix # 音频与多媒体 (PipeWire, RTKit)
    ./modules/services/desktop-niri.nix # 桌面环境与显示管理 (Niri, DMS greeter) — Niri 分支
    ./modules/services/sandbox.nix # 沙盒与容器 (Flatpak)
    ./modules/services/system-daemons.nix # 系统级守护进程 (fwupd, earlyoom)
  ];

  # 启用可重新分发的固件
  hardware.enableRedistributableFirmware = true;

  # 时区和语言设置
  time.timeZone = "Asia/Shanghai";

  # ✅ 显式声明 hostId（可复现性优化）
  # 作用: 某些 NixOS 模块（如 ZFS/系统服务）需要稳定的 hostId
  #       声明后配置可复现，不依赖 /etc/machine-id 的隐式生成
  # 注意: 此值由 machine-id 前 8 位派生（ee7b4b79），固定不变
  # 官方选项: https://search.nixos.org/options?query=networking.hostId
  networking.hostId = "ee7b4b79";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 用户配置
  users.groups.i2c = { }; # i2c 组（ddcutil 访问 /dev/i2c-N 需要）
  users.users.zhangchongjie = {
    isNormalUser = true; # 普通用户
    description = "zhangchongjie";
    # 添加 netadmin 权限以允许 Clash 创建 TUN 设备
    # gamemode 组：允许无密码切换 CPU governor（cpugovctl）
    # 依据: https://wiki.nixos.org/wiki/GameMode "Verifying Optimisations" 章节
    extraGroups = [
      "networkmanager"
      "wheel"
      "flatpak"
      "video"
      "render"
      "input"
      "gamemode"
      "i2c" # 访问 /dev/i2c-N（ddcutil 调外接显示器亮度需要）
    ];
    # 设置默认 shell 为 fish
    shell = pkgs.fish;
  };

  # ═══════════════════════════════════════════════════════════
  # （journald 日志配置已迁移至 ./modules/storage/ssd.nix）
  # 目的：日志不落盘（Storage=volatile），减少 SSD 写入
  # ═══════════════════════════════════════════════════════════

  # Fish Shell（系统级）
  programs.fish.enable = true;

  # 允许 unfree 包
  nixpkgs.config = {
    allowUnfree = true;
  };

  # ═══════════════════════════════════════════════════════════
  # (KDE 包集裁剪 overlay 已删除 —— COSMIC 不捆绑 KDE 元包，无需 overrideScope)
  # ═══════════════════════════════════════════════════════════

  # 系统软件包 - 仅保留系统级必需的工具
  environment.systemPackages = with pkgs; [
    # 系统核心工具
    home-manager # Home Manager（NixOS 集成模式）

    # KDE Connect（手机与电脑互联）— 用户明确保留，不依赖 Plasma 桌面
    kdePackages.kdeconnect-kde

    # 全局依赖库
    ffmpeg-full # 完整的 FFmpeg（多媒体库）
    unzip # Zip 解压缩工具

    # Nix 代码格式化工具
    nixfmt # Nix 格式化器
    nixd # Nix 语言服务器

    # 图标主题
    papirus-icon-theme
  ];

  # Nix 配置优化
  nix = {
    settings = {
      trusted-users = [
        "root"
        "zhangchongjie"
      ];

      # 二进制缓存镜像（优先级从高到低）
      substituters = [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;

      min-free = lib.mkDefault 2147483648;
      max-free = lib.mkDefault 8589934592;

      connect-timeout = 10; # 连接超时 10 秒（默认 0 无   超时）
      log-lines = 25; # 构建失败时显示 25 行日志（默认 10 行）
    };

    gc = {
      automatic = true;
      # weekly + 14d：降频 GC 减少 /nix/store 写入频次（配合 SSD 优化）
      # 官方选项: https://search.nixos.org/options?query=nix.gc.automatic
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise.automatic = true;
  };

  # ── 指纹认证服务 (fprintd + libfprint 主库) ────────────────
  # 目的：启动 fprintd 守护进程，安装含 Synaptics 驱动的 libfprint
  # 依赖：本机 USB 指纹锁 06cb:00f0；与 SDDM/KDE 无冲突（fprintd 是独立 D-Bus 服务）
  services.fprintd.enable = true;

  # 治本: login PAM 不启用 gnome_keyring auto_start
  # （tty 密码登录会设 keyring 密码 → 指纹登录无法解锁 → "unlock login keyring" 弹框）
  # 桌面登录走 dms-greeter（PAM 无 auto_start）——keyring 保持空密码自动解锁
  security.pam.services.login.enableGnomeKeyring = lib.mkForce false;



  # 禁用 speech-dispatcher（语音合成）——用户不用，且子进程全僵尸（sd_voxin 等）
  services.speechd.enable = false;

  # ── i2c-dev 设备权限（ddcutil 调外接显示器亮度）────────────
  # 依据: https://www.ddcutil.com/i2c_permissions
  # 内核创建 /dev/i2c-N 默认 root:root，需 udev 规则改为 i2c 组
  services.udev.extraRules = ''
    SUBSYSTEM=="i2c-dev", GROUP="i2c", MODE="0660"
    # 指纹设备（06cb:00f0）保持常开——防止周期挂起导致 xhci reset/指纹超时
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="06cb", ATTR{power/control}="on"
  '';


  # 设置 /etc/nixos 目录权限，允许 zhangchongjie 用户完全控制
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 zhangchongjie users -"
    "d /run/polkit-1/rules.d 0755 root root -"
    # 指纹设备（06cb:00f0）保持常开——udev ADD 规则只对插入生效，
    # 开机后设备已存在需 tmpfiles 写入（防止 xhci reset/指纹超时）
    "w /sys/bus/usb/devices/3-3.4/power/control - - - - on"
  ];

  # ═══════════════════════════════════════════════════════════
  # Home Manager 全局配置（NixOS 集成模式）
  # ═══════════════════════════════════════════════════════════
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.zhangchongjie =
      {
        lib,
        ...
      }:
      {
        imports = [
          ./home/default.nix
        ];
      };
  };

  # ═══════════════════════════════════════════════════════════
  # DMS (DankMaterialShell) 桌面 shell —— 完全由 nixpkgs 管理
  # 包 + NixOS 模块（更新 = nixpkgs 升级，无独立 flake input）
  # settings.json 由 home/dms.nix 的 home.file 声明（530 字段）
  # 注: 模块自动启用 power-profiles-daemon / accounts-daemon / i2c
  # ═══════════════════════════════════════════════════════════
  programs.dms-shell = {
    enable = true;
    # 用 flake 构建（含 #3171 指纹修复——v1.5.3 的 30 秒解锁 bug）
    # package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
    # systemd 服务 + 可选依赖（dgop/matugen/cava/khal）自动处理
  };

  # ── SMART 磁盘健康监控（NVMe/SSD 温度/寿命预警）──
  services.smartd.enable = true;

  # GeoClue2 定位（DMS 动态主题需要：日出日落判定 → 白天浅色/夜晚深色）
  # 之前缺失 → gammaIsDay 恒 false → 白天也深色
  services.geoclue2.enable = true;

  # DMS greeter 状态检查消除（让 dms greeter status 通过）
  # DMS 读 /etc/greetd/config.toml 找 dms 命令——NixOS 用 store 配置（文件不存在）
  # 创建声明式文件（greetd 实际仍用 store 配置——此文件仅 DMS 检查用）
  environment.etc."greetd/config.toml".text = ''
    [default_session]
    command = "dms-greeter --command niri"
    user = "dms-greeter"
  '';

  # 系统版本
  system.stateVersion = "26.11";
}
