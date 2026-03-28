# /etc/nixos/home/git.nix
# Git 版本控制配置
{ config, pkgs, lib, ... }:

{
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
