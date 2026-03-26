{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "25.11";

  # ═══════════════════════════════════════════════════════════
  # Fish Shell 配置
  # ═══════════════════════════════════════════════════════════
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
      
      # 目录导航使用 Fish 函数（避免特殊字符问题）
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

  # ═══════════════════════════════════════════════════════════
  # Git 配置
  # ═══════════════════════════════════════════════════════════
    programs.git = {
    enable = true;

    settings = {
      user = {
        name = "zhangchongjie";
        email = "778280151@qq.com";
      };

      init = {
        defaultBranch = "main";
      };

      core = {
        editor = "vim";
        autocrlf = "input";
        filemode = true;
        quotepath = false;  # 显示中文文件名
      };

      pull = {
        rebase = true;  # 默认使用 rebase
      };

      url."https://github.com/" = {
        insteadOf = "git://github.com/";
      };
      
      # 添加常用的 git 别名
      alias = {
        co = "checkout";
        br = "branch";
        ci = "commit";
        st = "status";
        last = "log -1 HEAD";
      };
      
      # 安全优化
      push = {
        default = "simple";  # 使用简单推送模式
        autoSetupRemote = true;  # 自动设置 upstream
      };
      
      fetch = {
        prune = true;  # 自动清理远程分支
      };
      
      # 性能优化
      pack = {
        threads = 0;  # 使用所有可用核心
      };

      # === 修正后的安全目录配置 ===
      # 使用嵌套结构来定义 safe.directory
      safe = {
        directory = [ "/etc/nixos" ];
      };
    };
  };
}
