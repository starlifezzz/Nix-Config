# /etc/nixos/home/vscode.nix
# VSCodium 配置 - 使用 Home Manager 统一管理 + Sync Settings 插件
{ config, pkgs, lib, pkgs-unstable, ... }:

let
  # ═══════════════════════════════════════════════════════════
  # ⚠️ 警告：此配置包含敏感信息，不应提交到 Git！
  # 请确保 ~/.config/VSCodium/User/sync-settings/config.yaml
  # 已被 .gitignore 忽略
  # ═══════════════════════════════════════════════════════════
  
  # Gitee Personal Access Token
  # 🔒 替换为你的实际 Token
  # 获取方式：https://gitee.com/profile/personal_access_tokens
  giteeToken = "464cf37f5d6c2f1acbd5abe47ee334b8";  # ← 在这里填入你的 token
  
in
{
  # ═══════════════════════════════════════════════════════════
  # VSCodium 基础配置
  # ═══════════════════════════════════════════════════════════
  programs.vscode = {
    enable = true;
    
    # 使用 VSCodium（无遥测的 VSCode 开源版本）
    package = pkgs.vscodium;
    
    # 禁用更新检查（VSCodium 需要手动更新）
    updateCheck = false;
    
    # 禁用遥测（隐私保护）
    mutableExtensionsDirectory = false;
    
    # ═══════════════════════════════════════════════════════════
    # Sync Settings 插件配置 - Gitee 远程同步
    # ═══════════════════════════════════════════════════════════
    extensions = with pkgs.vscode-extensions; [
      # zokugun.sync-settings - Git 同步配置（你指定的插件）
      zokugun.sync-settings
      
      # 其他推荐扩展（根据需要添加）
      # bbenoist.nix # Nix 语言支持
    ];
    
    # 用户设置（settings.json）
    userSettings = {
      # Sync Settings 插件配置
      "sync-settings.customLocalPath" = "${config.home.homeDirectory}/.config/VSCodium/User/sync-settings";
      
      # 基础编辑器设置
      "editor.fontSize" = 14;
      "editor.fontFamily" = "'JetBrains Mono', 'Fira Code', monospace";
      "editor.fontLigatures" = true;
      "editor.minimap.enabled" = true;
      "editor.wordWrap" = "on";
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "editor.formatOnSave" = true;
      "editor.renderWhitespace" = "selection";
      
      # 文件保存行为
      "files.autoSave" = "afterDelay";
      "files.autoSaveDelay" = 1000;
      "files.trimTrailingWhitespace" = true;
      "files.insertFinalNewline" = true;
      "files.trimFinalNewlines" = true;
      
      # 窗口与外观
      "window.zoomLevel" = 0;
      "workbench.colorTheme" = "Default Dark+";
      "workbench.iconTheme" = "material-icon-theme";
      
      # 终端集成
      "terminal.integrated.fontSize" = 13;
      "terminal.integrated.fontFamily" = "monospace";
      "terminal.integrated.defaultProfile.linux" = "fish";
      
      # Git 集成
      "git.enableSmartCommit" = true;
      "git.autorefresh" = true;
      "git.confirmSync" = true;
      
      # 性能优化
      "extensions.ignoreRecommendations" = false;
      "telemetry.telemetryLevel" = "off";
    };
    
    # 键盘快捷键（keybindings.json）
    keybindings = [
      # 快速保存并格式化
      {
        key = "ctrl+s";
        command = "workbench.action.files.save";
      }
    ];
  };
  
  # ═══════════════════════════════════════════════════════════
  # Sync Settings 独立配置文件（zokugun 插件格式）
  # ═══════════════════════════════════════════════════════════
  home.file.".config/VSCodium/User/sync-settings/config.yaml".text = ''
    # current machine's name, optional
    hostname: ""
    
    # selected profile, required
    profile: main
    
    # sync on remote git (Gitee)
    repository:
      type: git
      # HTTPS URL for Gitee
      url: https://gitee.com/wyrlovezcj/vscode-settings.git
      # branch to sync on
      branch: main
      # authentication token
      token: ${giteeToken}
      # commit message customization
      commitMessage: "chore: sync vscodium settings - %datetime%"
    
    # hooks (optional)
    hooks:
      post-upload: notify-send "VSCodium Settings" "Settings uploaded to Gitee!"
      post-download: notify-send "VSCodium Settings" "Settings downloaded from Gitee!"
  '';

  # ═══════════════════════════════════════════════════════════
  # 相关工具包
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # Git（同步必需）
    git
    
    # 通知工具（hooks 使用）
    libnotify
  ];
}
