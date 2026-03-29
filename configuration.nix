# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ config, lib, pkgs, pkgs-unstable, ... }:

{
  imports =
    [
      # 基础硬件检测模块（提供 hardware.cpu.manualModel 等选项）
      ./modules/hardware/detection.nix
      # # 硬件配置文件（包含文件系统和 BTRFS 配置）
      ./hardware-configuration.nix
    ];

  # 启动配置
  boot = {
    loader = {
      systemd-boot = {
        enable = true;#启动引导
        configurationLimit = 10;#启动引导文件数量限制
        consoleMode = "max";#显示模式
      };
      efi.canTouchEfiVariables = true;#允许修改efi变量
    };
    
    # 内核配置 - 使用最新稳定版内核
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [
      # ═══════════════════════════════════════════════════════════
      # USB 设备稳定性优化 - NixOS 官方推荐设置
      # ═══════════════════════════════════════════════════════════
      "usbcore.autosuspend=-1"         # 禁用 USB 自动挂起
      "usbcore.usbfs_memory_mb=1024"   # USBFS 内存
      
      # ═══════════════════════════════════════════════════════════
      # 显示器分辨率策略：自动检测 EDID 并适配最大分辨率
      # ═══════════════════════════════════════════════════════════
      # 已移除硬编码的 video=2560x1440@75 参数
      # KDE Plasma Wayland + KScreen 会自动检测显示器 EDID 信息
      # 并应用显示器支持的最大分辨率和刷新率
      # 支持热插拔自动切换（如更换 4K 显示器自动适配 4K）
    ];
    
    # 内核模块
    kernelModules = [ ];
    
    # 内核参数优化 - 仅保留桌面环境必要的优化
    kernel.sysctl = {
      # 内存管理 - 使用 lib.mkDefault 允许硬件模块覆盖
      "vm.swappiness" = lib.mkDefault 1;
      "vm.vfs_cache_pressure" = lib.mkDefault 100;
      
      # 文件系统优化
      "fs.inotify.max_user_watches" = 524288;
      "fs.file-max" = 2097152;
      
      # AMDGPU优化
      "vm.page-cluster" = lib.mkDefault 0;  # SSD 优化：禁用交换预读
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
  services.xserver.enable = true;  # 原生 Wayland
  services.desktopManager.plasma6.enable = true;

  # 打印服务（默认禁用）
  services.printing.enable = false;

  # 音频配置 - PipeWire
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
    # 根据 NixOS 官方文档，TUN 模式需要 NET_ADMIN capability
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "flatpak" 
      "video" 
      "render" 
      "input"
      "netadmin"  # ✅ 网络管理权限（TUN 模式必需）
    ];
    # 设置默认 shell 为 fish
    shell = pkgs.fish;
  };

  # Fish Shell（系统级）
  programs.fish.enable = true;

  # direnv 配置
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # 启用 nix-direnv 集成
  };

  # Firefox 浏览器
  programs.firefox.enable = true;

  # 允许 unfree 和 broken 包
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # 系统软件包 - 仅保留系统级必需的工具
  environment.systemPackages = with pkgs; [
    # 系统核心工具
    home-manager      # Home Manager（NixOS 集成模式）
    
    # 系统维护工具（需要 root 权限）
    timeshift         # 系统备份工具
  
    # 全局依赖库
    ffmpeg-full       # 完整的 FFmpeg（多媒体库）
    
    # ⚠️ 用户级应用由 Home Manager 管理（programs.x + home.packages）
    # 包括：vscode, vim, fish, alacritty, zellij, git, direnv, nodejs, python3, uv, 等
    clash-verge-rev
    kdePackages.kdeconnect-kde
  ];

# 传感器支持
  hardware.sensor.iio.enable = true;

  # services.dbus.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
      trusted-users = [ "root" "zhangchongjie" ];
      
      # 二进制缓存镜像（优先级从高到低）
      substituters = [
        # 主镜像源 - 中科大（最稳定，响应快）
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        
        # 备用镜像源 1 - 上海交通大学（稳定性优秀）
        "https://mirror.sjtu.edu.cn/nix-channels/store"
        
        # 备用镜像源 2 - 清华大学
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        
        # 官方源（最后的选择）
        "https://cache.nixos.org"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      keep-derivations = true;
      keep-outputs = true;

      # 并行构建配置 - 最大化利用资源但防止死机
      # ═══════════════════════════════════════════════════════════
      # max-jobs = "auto" 会根据 CPU 核心数自动调整
      # 配合下面的内存保护机制，实现"安全地榨干性能"
      max-jobs = "auto";  # ✅ 自动检测 CPU 核心数
      cores = 0;          # 使用所有核心（单个构建任务内部并行）
      
      # 🔥 关键：内存保护阈值（防止 OOM 死机的核心配置）
      # NixOS 官方推荐：预留总内存的 10-15% 作为安全线
      # 当可用内存低于此值时，Nix 会自动暂停新构建
      min-free = 2147483648;  # 2GB 空闲内存保护线（根据 16GB 内存设置）
      
      # 磁盘空间管理
      max-free = 4294967296;  # 4GB 最大空闲空间
      
      # ✅ 启用内存限制 cgroup（NixOS 25.11+ 新特性）
      # 这会给每个构建任务设置内存上限，超过则失败而非撑爆系统
      extra-platforms = [ ];

      # 沙箱配置
      sandbox = true;
      
      # 连接超时优化
      connect-timeout = 10;  # 降低超时时间，快速失败
      log-lines = 25;        # 增加日志行数
      
      # ✅ 不强制要求签名，允许从未签名的镜像源下载
      require-sigs = false;
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


  # 配置 Flatpak 镜像源 - 系统级
  systemd.services.flatpak-repo = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
      flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
    '';
  };


  # XDG Portal 配置 - KDE Plasma 环境
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.kdePackages.xdg-desktop-portal-kde  # KDE portal（完整实现）
    ];
    # 修改配置，确保兼容性
    config = {
      common = {
        default = [ "kde" ];  # 更正配置格式
      };
      # 为兼容性添加额外配置
      plasma = {
        default = [ "kde" ];
      };
    };
  };
    # 确保 D-Bus 服务启用，这对 Flatpak 应用很重要
  services.dbus.enable = true;

  # Zram 虚拟内存配置 - 作为内存缓冲层
  # ═══════════════════════════════════════════════════════════
  # 工作原理：将部分内存数据压缩存储，相当于"软件扩容"
  # 适用场景：突发高内存负载（如 Nix 构建、多任务处理）
  # 性能影响：轻微 CPU 开销（约 1-3%），但能防止 OOM 死机
  services.zram-generator.enable = true;

  # ═══════════════════════════════════════════════════════════
  # 🔥 内核级 OOM 保护配置
  # ═══════════════════════════════════════════════════════════
  # 说明：Linux 内核有内置的 OOM Killer 机制，当内存耗尽时会杀掉进程
  # 通过调整以下参数，可以让系统更早触发保护，避免完全死机
  boot.kernel.sysctl = {
    # OOM 检测灵敏度（0-100，默认 60）
    # 降低此值会让内核更早介入，防止系统完全无响应
    "vm.oom_kill_allocating_task" = 1;
    
    # 禁用过度使用内存的进程的 OOM 分数调整
    # 确保 Nix 构建进程在内存不足时优先被选中
    "vm.panic_on_oom" = 0;
  };
  
  # ═══════════════════════════════════════════════════════════
  # ✅ 推荐方案：使用 earlyoom 用户空间 OOM 守护进程
  # ═══════════════════════════════════════════════════════════
  # 这是比 systemd-oomd 更成熟的方案，已在 NixOS 官方仓库中
  # 功能：在内存耗尽前（默认剩余 5%）就主动杀掉占用最多的进程
  # 优势：避免系统完全死机，保留最后响应能力
  services.earlyoom.enable = true;
  
  # Avahi 服务（mDNS）
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 网络配置
  # ═══════════════════════════════════════════════════════════
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    # ═══════════════════════════════════════════════════════════
    # 防火墙配置 - 支持 Clash TUN 模式
    # ═══════════════════════════════════════════════════════════
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
      
      # 允许 Clash TUN 模式的虚拟网卡流量
      # 根据 NixOS 官方 issue #477636，TUN 模式需要信任 TUN 接口
      trustedInterfaces = [
        "Mihomo"  # ✅ Clash Verge Rev 的 TUN 接口名称
        "Meta"    # 备选：Clash Meta 内核的默认 TUN 接口
        "clash0"  # 备选 TUN 接口
        "utun*"   # 通用 TUN 接口通配符
      ];
      
      # 开放必要的端口
      # allowedTCPPorts = [ 
      #   7897  # Clash Dashboard
      #   7890  # Clash HTTP 代理端口
      #   7891  # Clash SOCKS5 代理端口
      #   9090  # Clash External Controller (可选)
      # ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
  };


  # ═══════════════════════════════════════════════════════════
  # 环境变量配置 - TUN 模式下无需全局代理设置
  # ═══════════════════════════════════════════════════════════

  # systemd-resolved DNS 服务（与 NetworkManager 协同工作）
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSStubListener = "yes";
        DNS = "119.29.29.29 223.5.5.5";
        DNSSEC = "false";
      };
    };
  };

  # 字体配置（系统级）
  fonts.packages = with pkgs; [
    # 中文支持
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    lxgw-wenkai-screen
    lxgw-wenkai
    
    # 英文和通用字体
    noto-fonts
    source-han-sans
    source-han-serif
    
    # 等宽字体（编程用）
    jetbrains-mono
    fira-code
    
    # 文泉驿字体（备用）
    wqy_zenhei
    wqy_microhei
  ];
  
  # 字体渲染优化
  fonts.fontconfig = {
    enable = true;
    
    defaultFonts = {
      serif = ["LXGW WenKai Screen" "LXGW WenKai" "Noto Serif CJK SC" "WenQuanYi Micro Hei" ];
      sansSerif = ["LXGW WenKai Screen" "LXGW WenKai" "Noto Sans CJK SC" "WenQuanYi Zen Hei" ];
      monospace = ["LXGW WenKai Screen" "LXGW WenKai" "Noto Sans Mono CJK SC" "WenQuanYi Micro Hei Mono"];
      emoji = ["Noto Color Emoji"];
    };
    
    antialias = true;
    hinting = {
      enable = true;
      autohint = true;
      style = "slight";
    };
    
    subpixel = {
      rgba = "rgb";
      lcdfilter = "default";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # Flatpak 字体访问支持（可选配置）
  # ═══════════════════════════════════════════════════════════
  # 注意：Flatpak 应用通常通过 Portal 自动访问系统字体
  # 此配置为某些需要直接访问 /usr/share/fonts 的旧应用提供兼容
  # 如果所有 Flatpak 应用字体正常，可以考虑移除此配置
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    fontsPkgs = config.fonts.packages ++ (with pkgs; [
        # 图标和光标主题（如有需要可在此添加）
      ]);
    x11Fonts = pkgs.runCommand "X11-fonts"
      {
        preferLocalBuild = true;
        nativeBuildInputs = with pkgs; [
          gzip
          pkgs.mkfontscale
          pkgs.mkfontdir
        ];
      }
      (''
        mkdir -p "$out/share/fonts"
        font_regexp='.*\.\(ttf\|ttc\|otb\|otf\|pcf\|pfa\|pfb\|bdf\)\(\.gz\)?'
      ''
      + (builtins.concatStringsSep "\n" (builtins.map (pkg: ''
          find ${toString pkg} -regex "$font_regexp" \
            -exec ln -sf -t "$out/share/fonts" '{}' \;
        '') fontsPkgs
        ))
      + ''
        cd "$out/share/fonts"
        mkfontscale
        mkfontdir
        cat $(find ${pkgs.font-alias}/ -name fonts.alias) >fonts.alias
      '');
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = fontsPkgs;
      pathsToLink = [
        "/share/icons"
      ];
    };
  in {
    "/usr/share/icons" = mkRoSymBind (aggregatedIcons + "/share/icons");
    "/usr/share/fonts" = mkRoSymBind (x11Fonts + "/share/fonts");
  };

  # SSD 优化 - 定期 TRIM
  services.fstrim.enable = true;

  # CPU 频率调节器
  powerManagement.cpuFreqGovernor = lib.mkForce "ondemand";

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

  # 设置 /etc/nix 目录权限，允许 users 组写入
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0775 root users -"
    "d /run/polkit-1/rules.d 0755 root root -"
  ];

  # ═══════════════════════════════════════════════════════════
  # Home Manager 全局配置（NixOS 集成模式）
  # ═══════════════════════════════════════════════════════════
  # ✅ 启用 Home Manager 作为 NixOS 模块
  # 这样在执行 nixos-rebuild switch 时会自动应用用户配置
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit pkgs-unstable; };
    
    # ✅ 定义用户配置（在 nixos-rebuild 时自动应用）
    users.zhangchongjie = { config, pkgs, ... }: {
      imports = [
        ./home/default.nix
      ];
      
      # 设置状态版本
      home.stateVersion = "25.11";
      
      # ✅ 自动清理备份文件 - 解决备份导致的混乱
      # 在每次 Home Manager 激活后，自动删除所有 .backup 和 .old 后缀的备份文件
      home.activation.cleanBackupFiles = ''
        # 清理 Home Manager 生成的备份文件
        if [ -d "$HOME/.config" ]; then
          find "$HOME/.config" -type f \( -name "*.backup" -o -name "*.old" \) -delete 2>/dev/null || true
        fi
        if [ -d "$HOME/.local/share/home-manager-backup" ]; then
          rm -rf "$HOME/.local/share/home-manager-backup"/* 2>/dev/null || true
        fi
        echo "✅ Cleaned up backup files"
      '';
    };
  };

  # 系统版本
  system.stateVersion = "25.11";
}
