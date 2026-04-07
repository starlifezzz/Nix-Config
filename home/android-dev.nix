# Home Manager 配置 - Android 开发环境
# 用于 Tauri Android 开发和原生 Android 应用开发
{ config, pkgs, lib, ... }:

let
  # Android SDK 路径
  androidSdkPath = "${config.home.homeDirectory}/Android/Sdk";
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
    android-udev-rules     # Android 设备 USB 规则
    
    # Android SDK 组件 (通过 androidenv 管理)
    (androidenv.androidPkgs.androidsdk.override {
      includeSystemImages = false;
      includeSources = false;
      includeDocs = false;
      platformVersions = [ "34" ];  # Android 14
      includeNDK = true;
      ndkVersions = [ "26" ];
      buildToolsVersions = [ "34.0.0" ];
      extraLicenses = [
        "android-sdk-preview-license"
        "android-googletv-license"
        "android-sdk-arm-dbt-license"
        "google-gdk-license"
        "intel-android-extra-license"
        "intel-android-sysimage-license"
        "mips-android-sysimage-license"
      ];
    })
    
    # 可选: 如果需要图形界面管理 SDK
    # android-studio  # 需要设置 allowUnfree = true
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
    
    # PATH 扩展
    PATH = lib.makeBinPath [
      pkgs.jdk17
      pkgs.android-tools
    ] + ":${androidSdkPath}/cmdline-tools/latest/bin:${androidSdkPath}/platform-tools:${androidSdkPath}/build-tools/34.0.0";
  };

  # ============================================
  # Shell 初始化脚本
  # ============================================
  home.activation.setupAndroidSdk = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p ${androidSdkPath}
    
    # 检查并初始化 Android SDK 结构
    if [ ! -d "${androidSdkPath}/platforms" ]; then
      echo "🔧 初始化 Android SDK 目录结构..."
      
      # 创建必要的目录
      $DRY_RUN_CMD mkdir -p ${androidSdkPath}/{platforms,build-tools,platform-tools,cmdline-tools}
      
      echo "✅ Android SDK 目录已创建: ${androidSdkPath}"
      echo ""
      echo "⚠️  首次使用需要安装 SDK 组件:"
      echo "   方式1: 使用 Android Studio (推荐)"
      echo "   方式2: 运行项目中的 setup-android-sdk.sh 脚本"
      echo ""
    fi
  '';

  # ============================================
  # VSCode 配置 (根据你的偏好)
  # ============================================
  programs.vscode = {
    enable = true;
    
    extensions = with pkgs.vscode-extensions; [
      # Android 开发相关
      google.flutter
      dart-code.dart-code
      
      # Rust/Tauri 开发
      rust-lang.rust-analyzer
      tamasfe.even-better-toml
      serayuzgur.crates
      
      # 通用开发
      ms-vscode.vscode-typescript-next
      vue.volar
    ];
    
    userSettings = {
      # Android 相关设置
      "dart.flutterSdkPath" = null;  # 自动检测
      "android.emulator.launchFlags" = "-no-snapshot-load";
      
      # Rust/Tauri 设置
      "rust-analyzer.linkedProjects" = [
        "src-tauri/Cargo.toml"
      ];
    };
  };

  # ============================================
  # Fish Shell 配置 (如果使用 fish)
  # ============================================
  programs.fish = {
    enable = true;
    
    shellInit = ''
      # Android 开发辅助函数
      function android-dev
        echo "🚀 启动 Android 开发环境"
        echo ""
        echo "可用命令:"
        echo "  tauri android init    - 初始化 Android 项目"
        echo "  tauri android dev     - 开发模式"
        echo "  tauri android build   - 构建 APK"
        echo "  adb devices           - 查看连接的设备"
        echo ""
      end
      
      function check-android-env
        echo "📋 检查 Android 开发环境"
        echo ""
        echo "JAVA_HOME: $JAVA_HOME"
        java -version 2>&1 | head -n 1
        echo ""
        echo "ANDROID_HOME: $ANDROID_HOME"
        test -d $ANDROID_HOME && echo "✅ Android SDK 目录存在" || echo "❌ Android SDK 目录不存在"
        echo ""
        echo "ADB 版本:"
        adb --version 2>/dev/null | head -n 1 || echo "❌ ADB 未找到"
        echo ""
      end
    '';
  };

  # ============================================
  # 文档和说明
  # ============================================
  home.file.".local/share/doc/android-dev-setup.md".text = ''
    # Android 开发环境配置指南
    
    ## 已配置的内容
    
    ### 1. Java 环境
    - JDK 17 已安装并配置
    - JAVA_HOME 已设置
    
    ### 2. Android 工具
    - android-tools (adb, fastboot)
    - Android SDK 基础结构
    
    ### 3. 环境变量
    ```bash
    JAVA_HOME=${pkgs.jdk17}
    ANDROID_HOME=$HOME/Android/Sdk
    PATH 包含所有必要工具
    ```
    
    ## 首次使用步骤
    
    ### 步骤 1: 重新加载 Home Manager
    ```bash
    home-manager switch
    # 或
    sudo nixos-rebuild switch
    ```
    
    ### 步骤 2: 验证环境
    ```bash
    check-android-env
    ```
    
    ### 步骤 3: 安装 Android SDK 组件
    
    **方式 A: 使用项目脚本 (推荐)**
    ```bash
    cd ~/Documents/Project/Ticktock
    ./setup-android-sdk.sh
    ```
    
    **方式 B: 手动安装**
    ```bash
    # 下载 Command Line Tools
    mkdir -p $ANDROID_HOME/cmdline-tools
    cd $ANDROID_HOME/cmdline-tools
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip commandlinetools-linux-11076708_latest.zip
    mv cmdline-tools latest
    rm commandlinetools-linux-11076708_latest.zip
    
    # 安装必要组件
    yes | sdkmanager --licenses
    sdkmanager "platforms;android-34" "build-tools;34.0.0" "platform-tools"
    ```
    
    ### 步骤 4: 初始化 Tauri Android 项目
    ```bash
    cd ~/Documents/Project/Ticktock
    nix-shell --run "tauri android init"
    ```
    
    ### 步骤 5: 连接设备或启动模拟器
    ```bash
    # 查看连接的设备
    adb devices
    
    # 如果没有设备,需要创建 AVD (Android Virtual Device)
    # 推荐使用 Android Studio 的 AVD Manager
    ```
    
    ### 步骤 6: 开始开发
    ```bash
    # 开发模式
    nix-shell --run "tauri android dev"
    
    # 构建 APK
    nix-shell --run "tauri android build"
    ```
    
    ## 常见问题
    
    ### Q: ADB 找不到设备?
    A: 确保手机开启开发者模式和 USB 调试,然后运行:
    ```bash
    adb kill-server
    adb start-server
    adb devices
    ```
    
    ### Q: 构建失败,提示缺少 SDK 组件?
    A: 运行 `sdkmanager` 安装缺失的组件:
    ```bash
    sdkmanager --list  # 查看已安装和可安装的组件
    sdkmanager "platforms;android-XX"  # 安装指定平台
    ```
    
    ### Q: 如何在 VSCode 中调试?
    A: 
    1. 安装 Dart/Flutter 扩展
    2. 打开项目
    3. 使用 Run and Debug 面板
    4. 选择 Android 设备作为目标
    
    ## 有用的命令
    
    ```bash
    # 查看所有连接的 Android 设备
    adb devices
    
    # 查看设备日志
    adb logcat
    
    # 安装 APK
    adb install app.apk
    
    # 卸载应用
    adb uninstall com.example.app
    
    # 进入设备 shell
    adb shell
    
    # 查看 Android SDK 已安装的组件
    sdkmanager --list_installed
    ```
    
    ## 参考资源
    
    - [Tauri Android 文档](https://tauri.app/v1/guides/mobile/android/)
    - [Android SDK 文档](https://developer.android.com/studio/command-line)
    - [ADB 命令参考](https://developer.android.com/studio/command-line/adb)
  '';

  # ============================================
  # 允许 unfree 包 (如果需要 Android Studio)
  # ============================================
  # 在 configuration.nix 或 home.nix 中添加:
  # nixpkgs.config.allowUnfree = true;
  # 然后取消注释下面的行:
  # home.packages = with pkgs; [ android-studio ];
}
