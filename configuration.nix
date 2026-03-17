# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/flatpak-fonts.nix  # flatpak字体配置
      ./modules/fonts.nix  #系统字体配置
    ];

  # Bootloader.
#   boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
    # 在boot.loader部分添加
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 10;  # 限制引导条目数量为10个
    consoleMode = "max";      # 使用最大可用分辨率
    # 或者指定具体分辨率
    # consoleMode = "1920x1080";
  };

  # 设置内核参数以提高显示质量
  boot.kernelParams = [
    # 设置帧缓冲区分辨率
#     "video=1920x1080@60"
    # 或者使用auto
    "video=efifb:auto"
  ];



  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

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

  # 输入法配置（使用正确的语法）
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-chinese-addons
        qt6Packages.fcitx5-configtool
      ];
      # 如果使用 Wayland 会话，启用 Wayland 前端
      waylandFrontend = true;
    };
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

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

   # 启用 fish shell 支持
  programs.fish.enable = true;

  users.users.zhangchongjie = {
    isNormalUser = true;
    description = "zhangchongjie";
    extraGroups = [ "networkmanager" "wheel" "flatpak" ];
#     添加这一行，将默认 shell 设置为 fish
    shell = pkgs.fish;
  };


  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  #  curl
  #  dig
     alacritty
     fish
     vim
     zellij
     lxgw-wenkai-screen
     lxgw-wenkai
     clash-verge-rev
     neofetch
     timeshift
     qt6Packages.fcitx5-configtool
     bleachbit
     git
     home-manager
     vscode
  ];

  # 确保桌面环境正确集成
  services.xserver.displayManager.setupCommands = ''
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx
    export QT_QPA_PLATFORM=wayland
  '';

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

  nix.settings = {
    # 将您的用户名和 root 设为可信用户
    trusted-users = [ "root" "zhangchongjie" ];
    # 配置二进制缓存镜像，可以添加多个，优先级从高到低
    substituters = [
      "https://mirrors.cernet.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    experimental-features = [ "nix-command" "flakes"];
  };


  # 启用 Flatpak 支持
  services.flatpak.enable = true;
  # Flatpak字体设置
  services.flatpak-fonts = {
    enable = true;
    userName = "zhangchongjie";  # 明确指定用户名
  };

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

  # 设置环境变量
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/nix/var/nix/profiles/default/share"
      "/run/current-system/sw/share"
      "/var/lib/flatpak/exports/share"
      "/home/zhangchongjie/.local/share/flatpak/exports/share"
    ];
#     # 字体相关环境变量
#     FONTCONFIG_PATH = "/etc/fonts";
#     FONTCONFIG_FILE = "/etc/fonts/fonts.conf";
  };

  # 确保字体暴露给 Flatpak /usr/share/fonts
  systemd.tmpfiles.rules = [
    # Flatpak 目录
    "d /var/lib/flatpak 0755 root flatpak -"
    "d /var/lib/flatpak/exports 0755 root flatpak -"
    "d /var/lib/flatpak/exports/share 0755 root flatpak -"
  ];

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


  # 防火墙配置
  networking.firewall = {
    enable = true;

    # KDE Connect
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];

    # ⭐ 只开放 API 端口（用于控制面板）
    allowedTCPPorts = [ 9090 ];
  };

}

