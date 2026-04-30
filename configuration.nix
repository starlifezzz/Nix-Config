# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  lib,
  pkgs,
  pkgs-unstable,
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
    ./modules/hardware/gpu/rx-5500.nix # 可选：r9-370, rx-5500, rx-6600xt

    # ═══════════════════════════════════════════════════════════
    # ✅ 网络和字体配置模块
    # ═══════════════════════════════════════════════════════════
    ./modules/network/default.nix
    ./modules/fonts/default.nix
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
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # ═══════════════════════════════════════════════════════════
      # USB 设备稳定性优化 - NixOS 官方推荐设置
      # ═══════════════════════════════════════════════════════════
      "usbcore.autosuspend=-1" # 禁用 USB 自动挂起
      "usbcore.usbfs_memory_mb=1024" # USBFS 内存

      # ═══════════════════════════════════════════════════════════
      # NVMe SSD 优化 - 解决 SUBNQN 警告（最小化性能影响）
      # ═══════════════════════════════════════════════════════════
      "nvme_core.io_timeout=4294967295" # 最大IO超时值（无性能影响）
      "nvme_core.max_retries=10" # 增加重试次数（仅在错误时生效）

      # ═══════════════════════════════════════════════════════════
      # 安全防护 - 移除性能影响大的参数
      # ═══════════════════════════════════════════════════════════
      # 移除 mds=full,nosmt (禁用SMT会影响多线程性能)
      # 保留基本防护但不影响性能
      "spectre_v2=on" # 启用 Spectre V2 防护（现代CPU硬件支持，性能影响极小）

      # ═══════════════════════════════════════════════════════════
      # ACPI 兼容性 - 减少 DSM 警告
      # ═══════════════════════════════════════════════════════════
      "acpi_enforce_resources=lax" # 宽松的 ACPI 资源管理

      # ═══════════════════════════════════════════════════════════
      # 显示器分辨率策略：自动检测 EDID 并适配最大分辨率
      # ═══════════════════════════════════════════════════════════
      # 已移除硬编码的 video=2560x1440@75 参数
      # KDE Plasma Wayland + KScreen 会自动检测显示器 EDID 信息
      # 并应用显示器支持的最大分辨率和刷新率
      # 支持热插拔自动切换（如更换 4K 显示器自动适配 4K）
    ];

    # 内核模块
    kernelModules = [
      "xpad" # Xbox 手柄驱动
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

      # AMDGPU优化
      "vm.page-cluster" = lib.mkDefault 0; # SSD 优化：禁用交换预读
      
      # ✅ Linux 7.0 XFS 自修复功能监控
      "fs.xfs.error_level" = 3; # 启用详细的XFS错误报告
      "fs.xfs.panic_mask" = 0;  # 不panic，只记录错误

      # ═══════════════════════════════════════════════════════════
      # ✅ 性能计数器权限 - 解决 "Could not retrieve perf counters (-19)" 问题
      # ═══════════════════════════════════════════════════════════
      "kernel.perf_event_paranoid" = 0; # 允许所有用户访问perf事件
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

  # Fcitx5 输入法
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
    ];
  };

  # KDE Plasma 6 桌面环境
  # services.xserver.enable = true; # 移除X11兼容层，Plasma 6默认使用Wayland
  services.desktopManager.plasma6.enable = true;

  # 打印服务（默认禁用）
  services.printing.enable = false;

  # 音频配置 - PipeWire（支持 DSD 硬解）
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ✅ UPower 服务 - 修复 WirePlumber 电池百分比错误
  services.upower.enable = true;

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
  nixpkgs.config.allowBroken = true;

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

  # 系统软件包 - 仅保留系统级必需的工具（包含 ALSA DSD 支持）
  environment.systemPackages = with pkgs; [
    # 系统核心工具
    home-manager # Home Manager（NixOS 集成模式）

    # 系统维护工具（需要 root 权限）
    # timeshift         # 系统备份工具

    # 全局依赖库
    ffmpeg-full # 完整的 FFmpeg（多媒体库）

    # Nix 代码格式化工具
    nixfmt # Nix 格式化器

    # ⚠️ 用户级应用由 Home Manager 管理（programs.x + home.packages）
    # 包括：vscode, vim, fish, alacritty, zellij, git, direnv, nodejs, python3, uv, 等
    clash-verge-rev
    kdePackages.kdeconnect-kde
  ];

  # 传感器支持
  hardware.sensor.iio.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Nix 配置优化
  nix = {
    settings = {
      trusted-users = [
        "root"
        "zhangchongjie"
      ];

      # 二进制缓存镜像（优先级从高到低）
      substituters = [
        # 清华源 
       "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" 

        # 主镜像源 - 中科大（最稳定，响应快）
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        
        # 备用镜像源 1 - 上海交通大学（稳定性优秀）
        "https://mirror.sjtu.edu.cn/nix-channels/store"

        # 官方源（最后的选择）
        # "https://cache.nixos.org"
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

      # 并行构建配置 - 限制并行作业数量防止内存溢出
      # ═══════════════════════════════════════════════════════════
      # max-jobs = "auto" 会根据 CPU 核心数自动调整
      # 配合下面的内存保护机制，实现"安全地榨干性能"
      max-jobs = "auto"; # ✅ 自动检测 CPU 核心数
      cores = 0; # 使用所有核心（单个构建任务内部并行）

      # 🔥 关键：增加内存保护阈值
      # 对于16GB内存系统，建议预留更多内存给系统
      min-free = lib.mkDefault 2147483648; # 2GB 空闲磁盘空间保护线（原来是1GB）

      # 磁盘空间管理
      # 使用 lib.mkDefault 允许硬件模块覆盖此值
      max-free = lib.mkDefault 8589934592; # 8GB 最大空闲空间（从4GB增加到8GB，更好地清理空间）

      # ✅ 启用内存限制（如果支持）
      # 这会给每个构建任务设置内存上限，超过则失败而非撑爆系统
      build-memory-limit = 2147483648; # 每个构建任务限制2GB内存（可选）

      # 沙箱配置
      sandbox = true;

      # 连接超时优化
      connect-timeout = 10; # 降低超时时间，快速失败
      log-lines = 25; # 增加日志行数

      # ✅ 不强制要求签名，允许从未签名的镜像源下载
      require-sigs = false;

      # ✅ 构建超时保护 - 防止单个 derivations 卡死超过 1 小时
      build-timeout = 3600;
    };

    # 垃圾回收
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };

    # 存储优化
    optimise.automatic = true;
  };

  # Flatpak 配置
  services.flatpak.enable = true;

  # XDG Portal 配置 - KDE Plasma 环境
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde # KDE portal（完整实现）
    ];
    config = {
      common.default = [ "kde" ];
    };
  };

  # 确保 D-Bus 服务启用（Flatpak 应用必需）
  services.dbus.enable = true;

  # ═══════════════════════════════════════════════════════════
  # ✅ 推荐方案：使用 earlyoom 用户空间 OOM 守护进程
  # ═══════════════════════════════════════════════════════════
  # 这是比 systemd-oomd 更成熟的方案，已在 NixOS 官方仓库中
  # 功能：在内存耗尽前（默认剩余 5%）就主动杀掉占用最多的进程
  # 优势：避免系统完全死机，保留最后响应能力
  services.earlyoom = {
    enable = true;
    # ✅ 针对 Nix 构建场景优化阈值
    # 默认 10% 对于构建来说太激进，降低到 5% 给构建更多缓冲空间
    freeMemThreshold = 5; # 内存低于 5% 时触发 SIGTERM
    freeSwapThreshold = 5; # Swap 低于 5% 时触发 SIGKILL

    # ✅ 保护关键系统进程和桌面环境
    # 注意：由于 systemd 引号转义问题，暂时不使用 --avoid 和 --prefer 参数
    # 让 earlyoom 使用默认策略（根据 RSS 内存占用选择进程）
    # 如需自定义，可通过配置文件方式实现
  };

  # SSD 优化 - 定期 TRIM
  services.fstrim.enable = true;

  # SDDM 显示管理器配置
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      General = {
        EnableAvatars = false;
        InputMethod = "qtvirtualkeyboard";
      };
    };
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
  # ✅ 启用 Home Manager 作为 NixOS 模块
  # 这样在执行 nixos-rebuild switch 时会自动应用用户配置
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # ❌ 已移除 backupFileExtension - 不再备份

    # ✅ 定义用户配置（在 nixos-rebuild 时自动应用）
    users.zhangchongjie =
      { config, pkgs,lib, ... }:
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
  system.stateVersion = "26.05";
}
