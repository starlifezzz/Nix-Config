# /etc/nixos/home/default.nix
# Home Manager 主配置文件 - 统一管理所有应用配置
{ config, pkgs, lib, pkgs-unstable, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "25.11";

  # 禁用 Nixpkgs 版本检查（因为我们在用 unstable）
  home.enableNixpkgsReleaseCheck = false;

  # ═══════════════════════════════════════════════════════════
  # 启用 Home Manager systemd 服务 - 关键配置！
  # ═══════════════════════════════════════════════════════════
  programs.home-manager.enable = true;

  # ═══════════════════════════════════════════════════════════
  # XDG 桌面集成
  # ═══════════════════════════════════════════════════════════
  # 启用 XDG 规范支持（管理 XDG 目录、MIME 类型等）
  xdg.enable = true;

 # 配置 XDG 用户目录（符合 freedesktop.org 标准）
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = false;
    desktop = "$HOME/Desktop";
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    publicShare = "$HOME/Public";
    templates = "$HOME/Templates";
  };

  # ═══════════════════════════════════════════════════════════
  # MIME 类型关联 - 简化配置，让 KDE 自动管理动态部分
  # ═══════════════════════════════════════════════════════════
  # 根据记忆中的规范：MIME 关联属于纯动态配置，不应该强制声明式管理
  # 只保留必要的静态关联，避免使用 force = true
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    # 只声明基础 Web 浏览器的 MIME 关联
    # 其他应用（如 Lutris、VSCode）的 MIME 关联由 KDE 动态管理
    defaultApplications = {
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 桌面快捷方式 - 手动指定 .desktop 文件链接
  # ═══════════════════════════════════════════════════════════
  # Home Manager 不会自动扫描 home.packages 创建快捷方式
  # 必须使用 xdg.dataFile 显式链接到 ~/.local/share/applications/
  xdg.dataFile."applications/net.lutris.Lutris.desktop".source = 
    "${pkgs.lutris}/share/applications/net.lutris.Lutris.desktop";

  # ═══════════════════════════════════════════════════════════
  # 用户软件包 - 包含所有需要通过 Home Manager 安装的包
  # ═══════════════════════════════════════════════════════════
  # ⚠️ 注意：虽然官方文档建议只用 programs.x，
  # 但在 NixOS 集成模式下，双保险策略可以确保：
  # 1. 桌面图标正常显示
  # 2. PATH 自动配置
  # 3. 避免 profile 链接问题导致应用丢失
  # 
  # 如果未来遇到 "two different versions" 错误，
  # 需要从 home.packages 中移除对应的包。
  home.packages = with pkgs; [
    # ═══════════════════════════════════════════════════════════
    # 字体
    # ═══════════════════════════════════════════════════════════
    jetbrains-mono
    fira-code
    
    # ═══════════════════════════════════════════════════════════
    # Shell 和终端工具（与 programs.x 双保险）
    # ═══════════════════════════════════════════════════════════
    fish              # Fish Shell
    alacritty         # Alacritty 终端模拟器
    zellij            # Terminal multiplexer
    
    # ═══════════════════════════════════════════════════════════
    # 版本控制和编辑器（与 programs.x 双保险）
    # ═══════════════════════════════════════════════════════════
    git               # Git 版本控制
    # vim             # ← Vim 已通过 programs.vim 管理，避免冲突！
    vscode            # VSCode 编辑器
    
    # ═══════════════════════════════════════════════════════════
    # 开发环境工具（与 programs.x 双保险）
    # ═══════════════════════════════════════════════════════════
    direnv            # Direnv 环境变量管理
    
    # ═══════════════════════════════════════════════════════════
    # 开发运行时（不支持 programs.x）
    # ═══════════════════════════════════════════════════════════
    nodejs            # Node.js 运行时
    python3           # Python 3 解释器
    uv                # Python 包管理器
    
    # ═══════════════════════════════════════════════════════════
    # 系统信息工具
    # ═══════════════════════════════════════════════════════════
    fastfetch
    
    # ═══════════════════════════════════════════════════════════
    # GUI 应用（需要桌面快捷方式）
    # ═══════════════════════════════════════════════════════════
    clash-verge-rev
    kdePackages.kdeconnect-kde
    
    # ═══════════════════════════════════════════════════════════
    # 游戏相关
    # ═══════════════════════════════════════════════════════════
    lutris
  ];

  # ═══════════════════════════════════════════════════════════
  # 环境变量
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    # ═══════════════════════════════════════════════════════════
    # Wayland 专用配置
    # ═══════════════════════════════════════════════════════════
    # 启用 Firefox 的 Wayland 支持
    MOZ_ENABLE_WAYLAND = "1";
    # Qt 应用优先使用 Wayland，回退到 XCB
    QT_QPA_PLATFORM = "wayland;xcb";
    # GTK 应用优先使用 Wayland，回退到 X11
    GDK_BACKEND = "wayland,x11";
    # 明确会话类型为 Wayland
    XDG_SESSION_TYPE = "wayland";
    # Clutter 工具包使用 Wayland
    CLUTTER_BACKEND = "wayland";
    # SDL 应用使用 Wayland
    SDL_VIDEODRIVER = "wayland";
    # Electron 应用自动选择平台
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # ═══════════════════════════════════════════════════════════
  # 导入所有应用配置模块
  # ═══════════════════════════════════════════════════════════
  imports = [
    # 基础 Shell 和版本控制
    ./fish.nix          # Fish Shell 配置
    ./git.nix           # Git 版本控制配置
    
    # 终端模拟器和 Multiplexer
    ./alacritty.nix     # Alacritty 终端模拟器配置
    ./zellij.nix        # Zellij Terminal Multiplexer 配置
    
    # 开发环境工具
    ./direnv.nix        # Direnv 开发环境配置
    
    # 代码编辑器
    # ./vscode.nix        # VSCode 代码编辑器配置
    ./vim.nix           # Vim 文本编辑器配置
    
    # 桌面环境
    ./kde.nix           # KDE Plasma 6 详细设置
    
    # 占位符文件（保留以便未来扩展）
    ./home.nix          # 基础配置占位符
  ];
}
