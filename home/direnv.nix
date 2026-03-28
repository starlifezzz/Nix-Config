# /etc/nixos/home/direnv.nix
# Direnv 开发环境配置
{ config, pkgs, lib, ... }:

{
  programs.direnv = {
    enable = true;
    
    # 启用 nix-direnv 集成
    nix-direnv.enable = true;
    
    # 配置 direnv 的行为
    config = {
      # 禁用警告信息
      warn_timeout = 0;
      
      # 启用日志
      log_format = "json";
      log_filter = "info";
    };
    
    # 全局环境变量
    global = {
      # 添加额外的 PATH
      # PATH_add = "...";
    };
  };
}
