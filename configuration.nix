# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/flatpak-fonts.nix  # flatpak字体配置
      # ./modules/amd-gpu.nix  # AMD GPU 配置（新增）
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
    
    # 内核配置
    kernelPackages =  pkgs.linuxPackages_latest; # 使用最新稳定版内核，官方默认内核
    kernelParams = [
      "video=1920x1080@60"
    ];

    # 内核参数优化
    kernel.sysctl = {
      # 网络优化
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.core.default_qdisc" = "cake";
      "net.core.rmem_max" = 134217728;
      "net.core.wmem_max" = 134217728;
      
      # 内存优化
      "vm.swappiness" = 1;
      "vm.vfs_cache_pressure" = 100;
      "vm.dirty_ratio" = 10;
      "vm.dirty_background_ratio" = 5;
      
      # 文件系统优化
      "fs.inotify.max_user_watches" = 524288;
      "fs.file-max" = 2097152;
    };
  };


  # Use latest kernel.
  # boot.kernelPackages = pkgs.linuxPackages_zen;


  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # Select internationalisation properties.
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


  # 桌面环境配置
  services.xserver = {
    enable = true;
    
    # 键盘布局
    xkb.layout = "cn";
    xkb.variant = "";
    
    # 输入法环境变量
    displayManager.setupCommands = ''
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
    '';
  };
  
  # Fcitx5 输入法
  i18n.inputMethod = {
    enable = true; # 启用输入法
    type = "fcitx5"; 
    fcitx5.addons = with pkgs; [ # 添加输入法扩展包
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
      qt6Packages.fcitx5-configtool
    ];
  };


  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb = {
  #   layout = "cn";
  #   variant = "";
  # };

  # Enable CUPS to print documents.
  #打印服务
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # 用户配置
  users.users.zhangchongjie = {
    isNormalUser = true; # 普通用户
    description = "zhangchongjie";
    extraGroups = [ "networkmanager" "wheel" "flatpak" "video" "render" "input"];
    shell = pkgs.fish; # fish shell启用
  };
  # Fish Shell（系统级）
  programs.fish.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     alacritty
     fish
     vim
     zellij
     neofetch
     git
     home-manager
     kdePackages.kdeconnect-kde
     clash-verge-rev
     timeshift
     qt6Packages.fcitx5-configtool
     bleachbit
     vscode
     lutris-free
     protonup-qt
     libvdpau-va-gl    # VDPAU 加速
     libva-vdpau-driver # VA-API VDPAU 后端
     vdpauinfo         # VDPAU 信息工具
     ffmpeg-full       # 完整的 FFmpeg（支持硬件解码）
     # 桌面集成工具（新增）
     desktop-file-utils
     appstream-glib
     kdePackages.kconfig
     kdePackages.kwindowsystem
     gtk2
  ];

  hardware.sensor.iio.enable = true;

  services.dbus.enable = true;
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?


  # Nix 配置优化
  nix = {
    settings = {
      # 将您的用户名和 root 设为可信用户
      trusted-users = [ "root" "zhangchongjie" ];
      # 配置二进制缓存镜像，优先级从高到低
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
      # 自动优化存储
      auto-optimise-store = true;
      # 保留较少的 generations
      keep-derivations = true;
      keep-outputs = true;

      # 并行构建
      max-jobs = "auto";
      cores = 0;

      # 启用沙箱
      sandbox = true;
    };
    # 垃圾回收配置
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    # 存储优化
    optimise.automatic = true;
  };
 # Flatpak 配置
  services.flatpak = {
    enable = true;
  };
  # Flatpak 字体配置
  services.flatpak-fonts = {
    enable = true;
    userName = "zhangchongjie";
  };
  # Flatpak 目录结构
  systemd.tmpfiles.rules = [
    "d /var/lib/flatpak 0755 root flatpak -"
    "d /var/lib/flatpak/exports 0755 root flatpak -"
    "d /var/lib/flatpak/exports/share 0755 root flatpak -"
  ];

  # 配置XDG Portal - 这是关键
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
    # 配置KDE为默认portal
    config = {
      common.default = ["kde"];
    };
  };


  # 启用 zRAM
  zramSwap = {
    enable = true;
    # 可选：设置 zRAM 大小（默认是内存的 50%）
    memoryPercent = 50;  # 使用 50% 的内存作为 zRAM

    # 可选：设置压缩算法（默认是 lzo-rle）
    # 可用算法：lzo, lzo-rle, lz4, lz4hc, zstd
    algorithm = "zstd";

    # 可选：设置优先级（比磁盘 swap 高）
    priority = 100;
  };

    # 2. 启用 Avahi (mDNS) 服务 - 使用正确的选项名
  services.avahi = {
    enable = true;
    nssmdns4 = true;  # 注意：从 nssmdns 改为 nssmdns4
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };


   # 网络配置
  networking = {
    hostName = "nixos";   # 主机名
    networkmanager.enable = true; # 启用 NetworkManager
    # DNS 配置
    nameservers = [ "114.114.114.114" "223.5.5.5" ];
    # 防火墙配置
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
      allowedTCPPorts = [ 9090 ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
  };
  # systemd-resolved DNS 服务
  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      DNSStubListener=yes
      DNS=114.114.114.114 223.5.5.5
    '';
  };

  # 安全加固
  security.sudo.wheelNeedsPassword = true;  # wheel 组需要密码
  security.doas.enable = false;  # 禁用 doas（如果不需要）

  # 限制核心转储
  systemd.coredump.enable = false;

  # SSD 优化 - 启用定期 TRIM
  services.fstrim.enable = true;

  # AMD CPU 电源管理
  powerManagement.cpuFreqGovernor = "ondemand";  # 动态频率调节

}