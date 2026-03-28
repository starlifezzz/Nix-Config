# /etc/nixos/home/fish.nix
# Fish Shell 配置
{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
    '';

    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      rebuild = "sudo -E nixos-rebuild switch";
      rebuild-test = "sudo -E nixos-rebuild test";
      hm-switch = "home-manager switch";
      rebuild-flake = "rebuild-flake";
      rebuild-offline = "rebuild-offline";
      
      # 新增实用别名
      c = "clear";
      s = "sudo";
      sk = "sudo killall -9";
      update = "sudo nixos-rebuild switch";
      gc = "sudo nix-collect-garbage -d";
      optimise = "sudo nix-store --optimise";
      
      # NixOS 专用
      ns = "nix-shell";
      nrs = "sudo nixos-rebuild switch";
      nrt = "sudo nixos-rebuild test";
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
    };

    functions = {
      # 🔴 Flakes 重建命令（使用国内镜像）
      rebuild-flake = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos \
          --option substituters "https://mirrors.cernet.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store" \
          --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      '';

      # 🔴 离线重建命令
      rebuild-offline = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos --offline
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
