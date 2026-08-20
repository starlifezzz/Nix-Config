# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  lib,
  pkgs,
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
    ./modules/hardware/fingerprint.nix # USB 指纹锁 (Synaptics Prometheus 06cb:00df)

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
    ./modules/services/desktop.nix # 桌面环境与显示管理 (Plasma6, SDDM)
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
  users.users.zhangchongjie = {
    isNormalUser = true; # 普通用户
    description = "zhangchongjie";
    # 添加 netadmin 权限以允许 Clash 创建 TUN 设备
    extraGroups = [
      "networkmanager"
      "wheel"
      "flatpak"
      "video"
      "render"
      "input"
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
  # ✅ 覆盖 KDE 包集 - 阻止不需要的应用被安装
  # ═══════════════════════════════════════════════════════════
  # 问题：KDE 元包会强制捆绑大量不需要的应用
  # 解决：使用 overrideScope 将不需要的包替换为空包
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (
        kdeFinal: kdePrev: {
          # 二维码扫描器（不需要）
          qrca = final.runCommand "qrca-empty" { } "mkdir -p $out";

          # Konsole 终端（已有 Alacritty + Zellij，不需要）
          konsole = final.runCommand "konsole-empty" { } "mkdir -p $out";
        }
      );
    })
  ];

  # 系统软件包 - 仅保留系统级必需的工具
  environment.systemPackages = with pkgs; [
    # 系统核心工具
    home-manager # Home Manager（NixOS 集成模式）

    # kdePackages.kdeconnect # KDE Connect（手机与电脑互联）
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

  # 设置 /etc/nixos 目录权限，允许 zhangchongjie 用户完全控制
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 zhangchongjie users -"
    "d /run/polkit-1/rules.d 0755 root root -"
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

        # 清理图标缓存激活脚本
        home.activation.clearIconCache = lib.mkAfter ''
          if [ "$USER" = "zhangchongjie" ]; then
            echo "Clearing Plasma icon cache..."
            rm -f ~/.cache/icon-cache.kcache
            rm -f ~/.cache/plasma-svgelements-*
            rm -rf ~/.cache/plasmashell*
          fi
        '';
      };
  };

  # 系统版本
  system.stateVersion = "26.11";
}
