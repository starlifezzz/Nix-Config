# Home Manager 配置 - Android 开发环境
# 用于 Tauri Android 开发和原生 Android 应用开发
{ config, pkgs, lib, ... }:

let
  # 使用默认的 androidsdk 包(已包含基本工具)
  # 注意: 完整的 SDK 组件需要通过 sdkmanager 手动安装
  androidSdk = pkgs.androidsdk;
  
  # Android SDK 路径
  androidSdkPath = "${androidSdk}/libexec/android-sdk";
in
{
  # ============================================
  # Android 开发必需包
  # ============================================
  home.packages = with pkgs; [
    # Java Development Kit (Android 构建必需)
    jdk17
    
    # Android 命令行工具
    android-tools          # adb, fastboot 等工具
    
    # Android SDK (基础版本)
    androidSdk
  ];

  # ============================================
  # 环境变量配置
  # ============================================
  home.sessionVariables = {
    # Java 环境
    JAVA_HOME = "${pkgs.jdk17}";
    
    # Android SDK 环境
    ANDROID_HOME = androidSdkPath;
    ANDROID_SDK_ROOT = androidSdkPath;
    
    # PATH 扩展 - 添加 Android 工具
    PATH = lib.makeBinPath [
      pkgs.jdk17
      pkgs.android-tools
      androidSdk
    ];
  };

  # ============================================
  # Shell 初始化脚本
  # ============================================
  home.activation.setupAndroidSdk = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # 确保 Android SDK 目录存在并可写 (用于 sdkmanager 安装额外组件时的缓存等)
    $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/Android/Sdk
    
    echo "✅ Android SDK 已配置: ${androidSdkPath}"
    echo "ℹ️  如需安装额外组件(如系统镜像),可使用:"
    echo "   sdkmanager --list"
    echo "   sdkmanager 'platforms;android-XX'"
  '';

  # ============================================
  # 允许 unfree 包 (如果需要 Android Studio)
  # ============================================
  # 注意: Android SDK 的许可证已通过 override 方式在上方自动接受。
  # 如果还需要安装 Android Studio (unfree)，仍需在全局配置中允许 unfree:
  # nixpkgs.config.allowUnfree = true;
  # 然后取消注释下面的行:
  # home.packages = with pkgs; [ android-studio ];
}
