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
    # ═══════════════════════════════════════════════════════════
    # ✅ 硬件配置文件（包含文件系统和 BTRFS 配置）
    # 此文件不会被 Git 追踪，每台设备可以有自己的配置
    # ═══════════════════════════════════════════════════════════
    ./hardware-configuration.nix

    # ═══════════════════════════════════════════════════════════
    # ✅ CPU 和 GPU 配置文件
    # 修改这里来切换硬件配置
    # ═══════════════════════════════════════════════════════════
    ./modules/hardware/cpu/ryzen-5600.nix # 可选：ryzen-1600x, ryzen-2600, ryzen-3600, ryzen-5600
    ./modules/hardware/gpu/rx-6600xt.nix # 可选：r9-370, rx-5500xt, rx-6600xt

    # ═══════════════════════════════════════════════════════════
    # ✅ 功能模块
    # ═══════════════════════════════════════════════════════════
    ./modules/network/default.nix # 网络基础设施(防火墙、DNS、Avahi)
    ./modules/network/wifi-bluetooth.nix # WiFi 和蓝牙配置
    ./modules/fonts/default.nix

    # ═══════════════════════════════════════════════════════════
    # ✅ SSD 存储优化模块
    # ═══════════════════════════════════════════════════════════
    ./modules/storage/ssd.nix

    # ═══════════════════════════════════════════════════════════
    # ✅ 系统服务模块
    # ═══════════════════════════════════════════════════════════
    ./modules/services/audio.nix           # 音频与多媒体 (PipeWire, RTKit)
    ./modules/services/desktop.nix         # 桌面环境与显示管理 (Plasma6, SDDM)
    ./modules/services/sandbox.nix         # 沙盒与容器 (Flatpak)
    ./modules/services/system-daemons.nix  # 系统级守护进程 (fwupd, earlyoom)
  ];

  # 启用可重新分发的固件
  hardware.enableRedistributableFirmware = true;
  # 统一的固件配置 - 包含所有必需的固件
  hardware.firmware = [ pkgs.linux-firmware ];

  # 启动配置
  boot = {
    loader = {
      systemd-boot = {
        enable = true; # 启动引导
        configurationLimit = 10; # 启动引导文件数量限制
        consoleMode = "max"; # 显示模式
      };
      efi.canTouchEfiVariables = true; # 允许修改efi变量
    };

    # 内核配置 - 使用最新稳定版内核
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
    kernelParams = [
      # ═══════════════════════════════════════════════════════════
      # NVMe SSD 优化 - 解决 SUBNQN 警告和性能问题
      # ═══════════════════════════════════════════════════════════
      "nvme_core.default_ps_max_latency_us=0" # 禁用电源管理以提高性能
      "nvme_core.multipath=N" # 禁用多路径（单设备）
      "nvme_core.io_timeout=4294967295" # 最大IO超时

      # ═══════════════════════════════════════════════════════════
      # USB 设备稳定性优化 - NixOS 官方推荐设置
      # ═══════════════════════════════════════════════════════════
      "usbcore.autosuspend=-1" # 禁用 USB 自动挂起
      "usbcore.usbfs_memory_mb=1024" # USBFS 内存

      # ═══════════════════════════════════════════════════════════
      # 安全防护 - 移除性能影响大的参数
      # ═══════════════════════════════════════════════════════════
      # 移除 mds=full,nosmt (禁用SMT会影响多线程性能)
      # 保留基本防护但不影响性能
      "spectre_v2=on" # 启用 Spectre V2 防护（现代CPU硬件支持，性能影响极小）

      # ═══════════════════════════════════════════════════════════
      # 👍 注意：drm.gpu_recovery 和 drm.debug 已移至 GPU 模块
      #     避免内核参数重复定义
      # ═══════════════════════════════════════════════════════════

      # ═══════════════════════════════════════════════════════════
      # ACPI 兼容性 - 减少 DSM 警告
      # ═══════════════════════════════════════════════════════════
      "acpi_enforce_resources=lax" # 宽松的 ACPI 资源管理

      # ═══════════════════════════════════════════════════════════
      # ✅ Linux 7.0 性能优化 - ZSwap压缩交换缓存
      # ═══════════════════════════════════════════════════════════
      "zswap.enabled=1" # 启用ZSwap压缩交换缓存
      "zswap.compressor=zstd" # 使用zstd压缩算法（高效且快速）
      "zswap.max_pool_percent=20" # 最大使用20%内存作为压缩池

      # ═══════════════════════════════════════════════════════════
      # ✅ 透明大页优化 - 使用 madvise 模式（由 CPU 模块统一管理）
      # ═══════════════════════════════════════════════════════════
      # 注意：不在 configuration.nix 中设置 transparent_hugepage
      # 该参数由 CPU 模块统一管理，避免重复和冲突
    ];

    # 内核模块
    kernelModules = [
      "xpad" # Xbox 手柄驱动
      "ntsync" # NTSYNC内核驱动 - 提升Windows应用程序多线程同步性能
    ];

    # 黑名单模块 - 防止与手柄冲突
    blacklistedKernelModules = [
      "hid_nintendo" # 禁止 Switch 手柄驱动（避免与北通鲲鹏 20 冲突）
    ];

    # 内核参数优化 - 仅保留桌面环境必要的优化
    kernel.sysctl = {
      # 内存管理 - 使用 lib.mkDefault 允许硬件模块覆盖
      "vm.swappiness" = lib.mkDefault 1;
      "vm.vfs_cache_pressure" = lib.mkDefault 100;

      # 文件系统优化
      "fs.inotify.max_user_watches" = 524288;
      "fs.file-max" = 2097152;

      # ═══════════════════════════════════════════════════════════
      # ✅ 性能计数器权限 - 解决 "Could not retrieve perf counters (-19)" 问题
      # ═══════════════════════════════════════════════════════════
      "kernel.perf_event_paranoid" = 0; # 允许所有用户访问perf事件

      # ═══════════════════════════════════════════════════════════
      # ✅ Linux 7.0 容器和虚拟化性能优化
      # ═══════════════════════════════════════════════════════════
      "kernel.keys.root_maxbytes" = 25000000; # 增加root密钥环大小限制
      "kernel.keys.root_maxkeys" = 1000000; # 增加root密钥数量限制
    };
  };

  # 时区和语言设置
  time.timeZone = "Asia/Shanghai";
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
      "netadmin" # ✅ 网络管理权限（TUN 模式必需）
    ];
    # 设置默认 shell 为 fish
    shell = pkgs.fish;
  };

  # Fish Shell（系统级）
  programs.fish.enable = true;

  # direnv 配置
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # 启用 nix-direnv 集成
  };

  # Firefox 浏览器
  programs.firefox.enable = false;

  # 允许 unfree 和 broken 包
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = false;

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
    kdePackages.kdeconnect-kde

    # 全局依赖库
    ffmpeg-full # 完整的 FFmpeg（多媒体库）

    # Nix 代码格式化工具
    nixfmt # Nix 格式化器
    nixd # Nix 语言服务器
  ];

  # 传感器支持
  hardware.sensor.iio.enable = true;

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
        "https://mirror.sjtu.edu.cn/nix-channels/store"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      auto-optimise-store = true;
      keep-derivations = true;
      keep-outputs = true;

      max-jobs = "auto";
      cores = 0;

      min-free = lib.mkDefault 2147483648;
      max-free = lib.mkDefault 8589934592;

      sandbox = true;
      connect-timeout = 10;
      log-lines = 25;
      require-sigs = false;
      build-timeout = 3600;
      keep-build-log = false;
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    optimise.automatic = true;
  };

  # 设置 /etc/nixos 目录权限，允许 zhangchongjie 用户完全控制
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 zhangchongjie users -"
    "d /run/polkit-1/rules.d 0755 root root -"
  ];

  # 彻底解决磁盘空余不足
  boot.tmp = {
    useTmpfs = true;
    tmpfsSize = "12G";
  };

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