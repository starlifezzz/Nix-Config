# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ config, lib, pkgs, ... }:

{
  imports =
    [
      # 基础硬件检测模块（提供 hardware.cpu.manualModel 等选项）
      ./modules/hardware/detection.nix
      # # 硬件配置文件（包含文件系统和 BTRFS 配置）
      # ./hardware-configuration.nix
    ] 
      # # 硬件自动检测配置（已禁用）以后换电脑后都要先改这个！！！！！！！！！！！
      # ++ lib.optional (builtins.pathExists ./hardware-auto.nix) ./hardware-auto.nix
      ++ lib.optional (builtins.pathExists ./hardware-configuration-2600.nix) ./hardware-configuration-2600.nix;

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
    kernelPackages = pkgs.linuxPackages;
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
      
      # AMDGPU + BTRFS 优化
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
  services.xserver.enable = false;  # 原生 Wayland
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

  # 用户配置
  users.users.zhangchongjie = {
    isNormalUser = true; # 普通用户
    description = "zhangchongjie";
    extraGroups = [ "networkmanager" "wheel" "flatpak" "video" "render" "input" ];
    # 设置默认 shell 为 fish
    shell = pkgs.fish;
  };

  # Fish Shell（系统级）
  programs.fish.enable = true;

  # Firefox 浏览器
  programs.firefox.enable = true;

  # 允许 unfree 和 broken 包
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # 系统软件包
  environment.systemPackages = with pkgs; [
    # 基础工具
    vim
    git

    # 终端和开发工具
    alacritty
    zellij
    fastfetch
    home-manager
    pkgs.vscode
    
    # KDE 应用
    kdePackages.kdeconnect-kde
    
    # 网络工具
    clash-verge-rev  # 只保留一个 Clash GUI
    # flclash          # 备选
    
    # 系统维护工具
    timeshift
    bleachbit
    
    # pkgs.protonup-qt
    
    # GPU 工具（AMD）
    # vulkan-tools      # vulkaninfo
    # radeontop         # AMD GPU 监控
    pciutils          # lspci 工具
    
    # 多媒体支持
    ffmpeg-full       # 完整的 FFmpeg
    # kdePackages.plasma-workspace-wallpapers
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
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.cernet.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];

      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      keep-derivations = true;
      keep-outputs = true;

      # 并行构建
      max-jobs = "auto";
      cores = 0;

      # 启用沙箱
      sandbox = true;
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
      pkgs.kdePackages.xdg-desktop-portal-kde  # KDE portal（完整实现）
    ];
    # 不设置 default，让系统自动选择后端
    # config.common.default 留空以使用自动选择
  };

  # zRAM 配置
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
    priority = 100;
  };

  # Avahi 服务（mDNS）
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
    };
  };

  # 网络配置
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
      allowedTCPPorts = [ 7897 ];  # Clash Dashboard
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
  };


  #  # 系统范围的环境变量 - 包含代理设置
  # environment.variables = {
  #   HTTP_PROXY = "http://127.0.0.1:7897";
  #   HTTPS_PROXY = "http://127.0.0.1:7897";
  #   NO_PROXY = "127.0.0.1,localhost,*.local";
  # };


    # 全局环境变量（对所有程序生效，包括 Lutris）
  environment.variables = {
    HTTP_PROXY = "http://127.0.0.1:7897";
    HTTPS_PROXY = "http://127.0.0.1:7897";
    NO_PROXY = "localhost,127.0.0.1,::1,.localdomain.com";
  };

  # systemd-resolved DNS 服务
  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      DNSStubListener=yes
      DNS=119.29.29.29 223.5.5.5
    '';
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

  #flatpak读取系统字体权限
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    fontsPkgs = config.fonts.packages ++ (with pkgs; [
        # Add your cursor themes and icon packages here
        # etc.
      ]);
    x11Fonts = pkgs.runCommand "X11-fonts"
      {
        preferLocalBuild = true;
        nativeBuildInputs = with pkgs; [
          gzip
          xorg.mkfontscale
          xorg.mkfontdir
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
        cat $(find ${pkgs.xorg.fontalias}/ -name fonts.alias) >fonts.alias
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
  powerManagement.cpuFreqGovernor = "performance";

  # SDDM 显示管理器配置
  services.displayManager.defaultSession = "plasma";
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    
    settings = {
      General = {
        Background = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Mountain/contents/images/5120x2880.png";
        EnableAvatars = false;
        InputMethod = "qtvirtualkeyboard";
      };
    };
  };

  # 系统版本
  system.stateVersion = "25.11";
}