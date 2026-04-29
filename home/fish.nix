# /etc/nixos/home/fish.nix
# Fish Shell 配置
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.fish = {
    enable = true;

    shellInit = "";

    shellAliases = {
      # 基础命令
      ll = "ls -la";
      la = "ls -A";
      c = "clear";
      s = "sudo";
      sk = "sudo killall -9";
      
      # NixOS 系统管理
      rebuild = "sudo -E nixos-rebuild switch";
      rebuild-test = "sudo -E nixos-rebuild test";
      update = "sudo nixos-rebuild switch";
      nrs = "sudo nixos-rebuild switch";
      nrt = "sudo nixos-rebuild test";

      # Home Manager
      hm-switch = "home-manager switch";

      # 垃圾回收与优化
      gc = "sudo nix-collect-garbage -d";
      optimise = "sudo nix-store --optimise";

      # Nix 工具
      ns = "nix-shell";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      # clash快速启动
      start-clash = "cd /etc/nixos/scripts/ && sudo ./start-clash-tun.sh";
    };

    functions = {
      # 🔴 Flakes 重建命令（使用国内镜像源加速）
      rebuild-flake = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos \
          --option substituters "https://mirrors.cernet.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store" \
          --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      '';

      # 🔴 离线重建命令（无网络环境使用）
      rebuild-offline = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos --offline
      '';
      
      # 🔄 更新依赖并重建系统（一键完成 flake update + rebuild）
      rebuild-update = ''
        cd /etc/nixos && \
        sudo nix flake update && \
        sudo nixos-rebuild switch --flake .#nixos
      '';
      
      # 目录导航函数
      cdup = ''
        cd ..
      '';
      cd2up = ''
        cd ../..
      '';
      cd3up = ''
        cd ../../..
      '';
    };
  };
}
