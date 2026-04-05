# /etc/nixos/home/default.nix
# Home Manager 主配置文件 - 统一管理所有应用配置
{ config, pkgs, lib, pkgs-unstable, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "26.05";  # ✅ 与 system.stateVersion 保持一致

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
  # ✅ 注意：KDE 会根据系统 locale 自动创建目录名
  # 如果系统 locale 是中文，会创建"桌面"、"文档"等中文目录
  # 这里只启用基础功能，不强制指定路径，避免中英文目录并存
  xdg.userDirs = {
    enable = true;
    createDirectories = false;  # 让 KDE 根据 locale 自动管理
    setSessionVariables = false;
  };

  # ═══════════════════════════════════════════════════════════
  # MIME 类型关联 - Floorp 浏览器（替代 Firefox）
  # ═══════════════════════════════════════════════════════════
  # 根据记忆中的规范：MIME 关联属于纯动态配置，不应该强制声明式管理
  # 只保留必要的静态关联
  xdg.mime.enable = true;
  xdg.mimeApps = {
    enable = true;
    # 只声明基础 Web 浏览器的 MIME 关联
    # 其他应用（如 Lutris、VSCode）的 MIME 关联由 KDE 动态管理
    defaultApplications = {
      "text/html" = [ "floorp.desktop" ];
      "x-scheme-handler/http" = [ "floorp.desktop" ];
      "x-scheme-handler/https" = [ "floorp.desktop" ];
      "x-scheme-handler/about" = [ "floorp.desktop" ];
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 桌面快捷方式 - Lutris（lutris-free 版本）
  # ═══════════════════════════════════════════════════════════
  # Home Manager 不会自动扫描 home.packages 创建快捷方式
  # 必须使用 xdg.dataFile 显式链接到 ~/.local/share/applications/
  xdg.dataFile."applications/net.lutris.Lutris.desktop".source = 
    "${pkgs.lutris-free}/share/applications/net.lutris.Lutris.desktop";

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
    # 版本控制和编辑器
    vscode        # vscode 编辑器
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
    lutris-free
    
    # ═══════════════════════════════════════════════════════════
    # 🎵 音频播放器配置
    # ═══════════════════════════════════════════════════════════
    # cantata     # KDE 原生 MPD 客户端，支持 DSD
    # pavucontrol # PulseAudio 音量控制
    # playerctl   # 媒体控制器
    
   #下载相关
    parabolic
    yt-dlp
    motrix
    
   #浏览器
    floorp-bin
  ];

  # ═══════════════════════════════════════════════════════════
  # 环境变量 - 简洁配置
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    # ═══════════════════════════════════════════════════════════
    # Wayland 专用配置
    # ═══════════════════════════════════════════════════════════
    # 启用 Firefox 的 Wayland 支持
    MOZ_ENABLE_WAYLAND = "1";
    
    # Qt 应用优先使用 Wayland，回退到 XCB
    QT_QPA_PLATFORM = "wayland;xcb";
    
    # ⚠️ 注意：不设置全局 GDK_BACKEND，让 GTK 应用自行选择后端
    # 避免旧版 Electron 和 Flatpak 应用因强制 Wayland 而黑屏
    
    # 明确会话类型为 Wayland
    XDG_SESSION_TYPE = "wayland";
    
    # Clutter 工具包使用 Wayland
    CLUTTER_BACKEND = "wayland";
    
    # SDL 应用使用 Wayland
    SDL_VIDEODRIVER = "wayland";
    
    # ⚠️ 注意：ELECTRON_OZONE_PLATFORM_HINT 在 Electron 38+ 已移除
    # 需要时应在启动命令中传递 --ozone-platform=x11 参数
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
    ./vim.nix           # Vim 文本编辑器配置
    
    # 桌面环境
    ./kde.nix           # KDE Plasma 6 详细设置
    
    # ../configs/mpd-dsd.nix # MPD DSD 听歌配置
  ];
}
