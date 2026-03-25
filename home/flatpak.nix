# /etc/nixos/home/flatpak.nix
{ config, pkgs, lib, nix-flatpak, ... }:

{
  # 导入 nix-flatpak 模块
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # ═══════════════════════════════════════════════════════════
  # Flatpak 基础配置
  # ═══════════════════════════════════════════════════════════
  
  # 启用 Flatpak 支持
  services.flatpak.enable = true;
  
  # ═══════════════════════════════════════════════════════════
  # 已安装的应用（基于当前系统）
  # ═══════════════════════════════════════════════════════════
  services.flatpak.packages = [
    # 通讯工具
    "org.telegram.desktop"     # Telegram
    
    # 媒体播放
    "org.videolan.VLC"        # VLC 播放器
    
    # 实用工具
    "com.github.tchx84.Flatseal"      # Flatseal - Flatpak 权限管理工具
    "com.github.unrud.VideoDownloader" # Video Downloader - 视频下载工具
    
    # 国产应用（需要 flathub 以外的源或手动安装）
    # com.qq.QQ - Linux QQ（当前为系统级安装，建议保持）
    # com.tencent.WeChat - 微信（当前为系统级安装，建议保持）
    
    # 其他应用
    "io.ente.auth"            # Ente Auth - 双重验证工具
  ];
  
  # ═══════════════════════════════════════════════════════════
  # 远程仓库配置
  # ═══════════════════════════════════════════════════════════
  services.flatpak.remotes = [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];
  
  # ═══════════════════════════════════════════════════════════
  # 应用权限覆盖配置
  # ═══════════════════════════════════════════════════════════
  services.flatpak.overrides = {
    # 全局设置 - 优化 Wayland 支持
    global = {
      Context.sockets = [
        "wayland"
        "fallback-x11"  # 保留 fallback-x11 以兼容不支持 Wayland 的应用
      ];
      
      Environment = {
        # 修复图标主题
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
      };
    };
    
    # Telegram 特殊配置
    "org.telegram.desktop".Context = {
      filesystems = [
        "xdg-download"
        "xdg-documents"
      ];
    };
    
    # VLC 播放器配置
    "org.videolan.VLC".Context = {
      filesystems = [
        "xdg-videos"
        "xdg-music"
        "xdg-download"
      ];
    };
  };
  
  # ═══════════════════════════════════════════════════════════
  # 更新策略
  # ═══════════════════════════════════════════════════════════
  # 禁用自动更新，由用户手动控制
  services.flatpak.update.onActivation = false;
}
