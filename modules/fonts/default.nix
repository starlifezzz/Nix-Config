# ═══════════════════════════════════════════════════════════
# 字体配置模块
# ═══════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 字体包（系统级）
  # ═══════════════════════════════════════════════════════════
  fonts.packages = with pkgs; [
    # 中文支持（Noto CJK 包含简繁中日韩）
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    
    # 霞鹜文楷（主要显示字体，Screen 版本优化屏幕显示）
    lxgw-wenkai-screen
    lxgw-wenkai
    
    # 等宽字体（编程用）- JetBrains Mono 已足够
    jetbrains-mono
  ];
  
  # ═══════════════════════════════════════════════════════════
  # 字体渲染优化
  # ═══════════════════════════════════════════════════════════
  fonts.fontconfig = {
    enable = true;
    
    defaultFonts = {
      serif = ["LXGW WenKai Screen" "Noto Serif CJK SC"];
      sansSerif = ["LXGW WenKai Screen" "Noto Sans CJK SC"];
      monospace = ["JetBrains Mono" "LXGW WenKai Screen" "Noto Sans Mono CJK SC"];
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
  # ✅ Flatpak 字体访问 - NixOS 官方推荐方案
  # ═══════════════════════════════════════════════════════════
  # 说明：Flatpak 沙盒无法直接访问 Nix Store 中的字体
  # 官方方案：启用 fontDir + 简化 bindfs 挂载
  # 参考：https://wiki.nixos.org/wiki/Fonts#flatpak-applications-cant-find-system-fonts
  
  # ✅ 启用字体目录统一入口（/run/current-system/sw/share/X11/fonts）
  fonts.fontDir.enable = true;
  
  # ✅ 简化 bindfs 挂载 - 直接映射统一字体目录
  # 优势：无需复杂的 runCommand 和字体链接，配置简洁
  system.fsPackages = [ pkgs.bindfs ];
  fileSystems = {
    "/usr/share/fonts" = {
      device = "/run/current-system/sw/share/X11/fonts";
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
    
    # ✅ 同时挂载图标主题（Flatpak 应用需要）
    "/usr/share/icons" = {
      device = "/run/current-system/sw/share/icons";
      fsType = "fuse.bindfs";
      options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
    };
  };
}
