# /etc/nixos/home/rust-dev.nix
# Rust + Tauri + Naive UI 开发环境配置
{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Rust 开发工具链
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # Rust 核心工具链（通过 rustup 管理）
    rustup          # Rust 工具链安装器（包含 rustc, cargo, rustfmt, clippy）
    
    # Tauri CLI（用于构建 Tauri 应用）
    cargo-tauri     # Tauri 2.9.6 - 跨平台桌面应用框架
    
    # Node.js（Tauri 前端开发必需）
    nodejs_20       # Node.js 20 LTS - Tauri 2.x 推荐版本
    
    # 系统依赖（Linux Tauri 运行时必需）
    webkitgtk_4_1   # WebKitGTK 4.1 - Linux 平台 Tauri 渲染引擎
    gtk3            # GTK3 - GUI 工具包
    libsoup_3       # HTTP 库（WebKitGTK 依赖）
    
    # 系统托盘支持
    libayatana-appindicator  # AppIndicator 支持（系统托盘图标）
    
    # 编译和构建工具
    pkg-config      # 编译时查找库配置
    cmake           # CMake 构建系统
    openssl         # OpenSSL 加密库
    
    # 注意：以下库已通过 gtk3/webkitgtk_4_1 自动引入，无需重复声明
    # glib, cairo, pango, gdk-pixbuf, atk, librsvg, desktop-file-utils
    
    # 额外的 Rust 开发工具（可选但推荐）
    cargo-watch       # 文件变化监控和自动重建
    cargo-expand      # 宏展开调试工具
    cargo-audit       # 安全漏洞审计工具
    cargo-outdated    # 检查依赖更新
  ];

  # ═══════════════════════════════════════════════════════════
  # 环境变量配置
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    # Rust 相关环境变量
    CARGO_TERM_COLOR = "always";  # Cargo 输出彩色化
    
    # Node.js 相关
    NODE_ENV = "development";     # 默认开发环境
    
    # Tauri 开发优化
    TAURI_PLATFORM = "linux";     # 明确目标平台
  };

  # ═══════════════════════════════════════════════════════════
  # Shell 别名（Fish Shell）
  # ═══════════════════════════════════════════════════════════
  programs.fish.shellInit = ''
    # Rust 开发快捷命令
    alias cr='cargo run'
    alias cb='cargo build'
    alias ct='cargo test'
    alias cc='cargo check'
    alias cf='cargo fmt'
    alias cl='cargo clippy'
    
    # Tauri 开发命令
    alias td='cargo tauri dev'
    alias tb='cargo tauri build'
    
    # Rust 工具链管理
    alias rs='rustup show'
    alias ru='rustup update'
    alias ri='rustup install'
    
    # 快速创建新项目
    function new-rust-lib
        cargo new --lib $argv[1]
        and cd $argv[1]
        and echo "✅ Rust 库项目已创建: $argv[1]"
    end
    
    function new-tauri-app
        if test (count $argv) -lt 1
            echo "用法: new-tauri-app <project-name>"
            return 1
        end
        
        # 使用官方模板创建 Tauri 项目
        npm create tauri-app@latest $argv[1] -- --manager npm --template vanilla-ts
        and cd $argv[1]
        and npm install
        and echo "✅ Tauri 项目已创建: $argv[1]"
        and echo "💡 运行 'td' 启动开发服务器"
    end
  '';

  # ═══════════════════════════════════════════════════════════
  # XDG 配置（Naive UI 开发相关）
  # ═══════════════════════════════════════════════════════════
  # Naive UI 是 Vue 3 组件库，需要配合 Vite/Webpack 使用
  # 这里不直接安装包，而是确保 Node.js 环境就绪
  
  # 注释：Naive UI 通常通过 npm/yarn/pnpm 安装在项目中
  # 示例: npm install naive-ui vue
}
