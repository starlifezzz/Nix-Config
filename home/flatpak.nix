{ config, pkgs, lib, nix-flatpak, ... }:

{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # ═══════════════════════════════════════════════════════════
  # Flatpak 应用管理配置
  # ═══════════════════════════════════════════════════════════
  
  # 启用 Flatpak 支持
  services.flatpak.enable = true;
  
  # 配置要安装的 Flatpak 应用
  services.flatpak.packages = [
    # ═══════════════════════════════════════════════════════
    # 通讯工具
    # ═══════════════════════════════════════════════════════
    "org.telegram.desktop"     # Telegram
    "com.qq.QQ"  
    "com.tencent.WeChat"
    # "im.riot.Riot"            # Element/Matrix
    # "org.signal.Signal"       # Signal
    
    # ═══════════════════════════════════════════════════════
    # 媒体播放
    # ═══════════════════════════════════════════════════════
    "org.videolan.VLC"        # VLC 播放器
    # "com.spotify.Client"      # Spotify 音乐
    
    # ═══════════════════════════════════════════════════════
    # 办公生产力
    # ═══════════════════════════════════════════════════════
    # "org.libreoffice.LibreOffice"  # LibreOffice
    # "md.obsidian.Obsidian"         # Obsidian 笔记
    
    # ═══════════════════════════════════════════════════════
    # 开发工具
    # ═══════════════════════════════════════════════════════
    # "com.github.GitKraken"    # GitKraken Git 客户端
     "io.ente.auth"             # Ente 密码管理 
  ];
  
  # ═══════════════════════════════════════════════════════════
  # 配置 Flatpak 远程仓库
  # ═══════════════════════════════════════════════════════════
  services.flatpak.remotes = [
    # 主仓库 - Flathub (使用国内镜像加速)
    {
      name = "flathub";
      # 中国大陆用户建议使用以下镜像源之一：
      # 1. 中科大镜像 (推荐)
      # location = "https://mirrors.ustc.edu.cn/flatpak-repo/flatpak.flatpakrepo";
      # 2. 上海交通大学镜像
      location = "https://mirror.sjtu.edu.cn/flatpak-repo/flatpak.flatpakrepo";
      # 3. 清华大学镜像
      # location = "https://mirrors.tuna.tsinghua.edu.cn/flatpak-repo/flatpak.flatpakrepo";
      # 4. 官方源（如果镜像不可用）
      # location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
    
    # 可选：Flathub Beta 测试版仓库
    # {
    #   name = "flathub-beta";
    #   location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
    # }
  ];
  
  # ═══════════════════════════════════════════════════════════
  # 应用覆盖配置（可选）
  # ═══════════════════════════════════════════════════════════
  services.flatpak.overrides = {
    # 全局设置
    global = {
      # 默认使用 Wayland（如果支持）
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
      ];
      
      # 环境变量
      Environment = {
        # 修复某些应用的图标主题
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
        
        # 强制使用 GTK 主题
        # GTK_THEME = "Adwaita:dark";
      };
    };
    
    # VS Code 特殊配置
    "com.visualstudio.code".Context = {
      filesystems = [
        "xdg-config/git:ro"           # 访问 Git 配置
        "/run/current-system/sw/bin:ro"  # 访问 NixOS 系统命令
      ];
      sockets = [
        "gpg-agent"                   # GPG 密钥支持
        "pcsc"                        # 智能卡支持（如 YubiKey）
      ];
    };
    
    # OnlyOffice 需要 X11（无 Wayland 支持）
    "org.onlyoffice.desktopeditors".Context.sockets = [
      "x11"
      "wayland"
    ];
  };
  
  # ═══════════════════════════════════════════════════════════
  # 自动更新配置
  # ═══════════════════════════════════════════════════════════
  # 在系统重建时更新 Flatpak 应用
  services.flatpak.update.onActivation = true;
  
  # 或者启用定期更新（二选一）
  # services.flatpak.update.auto = {
  #   enable = true;
  #   onCalendar = "weekly";  # 每周自动更新
  # };
  
  # ═══════════════════════════════════════════════════════════
  # 管理策略
  # ═══════════════════════════════════════════════════════════
  # 设置为 true 会让 nix-flatpak 管理所有已安装的 Flatpak 应用
  # 包括通过命令行或应用商店安装的应用
  # 默认为 false，只管理声明式配置中的应用
  # services.flatpak.uninstallUnmanaged = false;
}
