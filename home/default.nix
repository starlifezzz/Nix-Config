# /etc/nixos/home/default.nix
{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "25.11";

  imports = [
    ./home.nix
    ./kde.nix
    ./font.nix
  ];


  # ═══════════════════════════════════════════════════════════
  # 用户软件包
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # 浏览器
    firefox

    # 其他
    flatpak
    # kdePackages.kate
    lutris-free
  ];


  # ═══════════════════════════════════════════════════════════
  # 启用 Home Manager
  # ═══════════════════════════════════════════════════════════
  programs.home-manager.enable = true;


    # ═══════════════════════════════════════════════════════════
  # 环境变量
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    XDG_DATA_DIRS = lib.makeSearchPath "" [
      "/nix/var/nix/profiles/default/share"
      "/run/current-system/sw/share"
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
  };
}