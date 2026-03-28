# /etc/nixos/home/vscode.nix
# VSCode 代码编辑器配置
{ config, pkgs, lib, pkgs-unstable, ... }:

{
  programs.vscode = {
    enable = true;
    
    # 使用 unstable 版本的 VSCode（获取最新功能）
    package = pkgs-unstable.vscode;
    
    # 扩展插件会在另一个文件中管理（可选）
    # extensions = with pkgs-vscode-extensions; [
    #   # 示例：常用扩展
    #   # bbenoist.nix
    #   # ms-python.python
    #   # ms-vscode.cpptools
    # ];
    
    # 用户设置
    userSettings = {
      # 基础设置
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'LXGW WenKai Mono', 'JetBrains Mono', monospace";
      "editor.minimap.enabled" = false;
      "editor.wordWrap" = "on";
      "editor.formatOnSave" = true;
      
      # 工作台设置
      "workbench.colorTheme" = "Default Dark Modern";
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.statusBar.visible" = true;
      
      # 文件关联
      "files.associations" = {
        "*.nix" = "nix";
        "*.md" = "markdown";
      };
      
      # Nix 语言支持
      "[nix]" = {
        "editor.defaultFormatter" = "jnoortheen.nix-ide";
      };
      
      # 终端集成
      "terminal.integrated.defaultProfile.linux" = "fish";
      "terminal.integrated.profiles.linux" = {
        "fish" = {
          "path" = "${pkgs.fish}/bin/fish";
        };
      };
    };
  };
}
