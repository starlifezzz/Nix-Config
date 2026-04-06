# 🦀 Rust + Tauri + Naive UI 开发环境

## 📦 已安装的核心组件

### Rust 工具链
- **rustup**: Rust 工具链管理器（包含 rustc、cargo、rustfmt、clippy）
- **cargo-tauri**: Tauri CLI v2.9.6（跨平台桌面应用框架）
- **Node.js 20 LTS**: Tauri 前端开发必需

### 系统依赖（Linux Tauri 运行时）
- **WebKitGTK 4.1**: Linux 平台渲染引擎
- **GTK3 + libsoup_3**: GUI 工具包和 HTTP 库
- **libayatana-appindicator**: 系统托盘图标支持
- **编译工具**: pkg-config, cmake, openssl, glib, cairo, pango 等

### 开发辅助工具
- **cargo-watch**: 文件监控和自动重建
- **cargo-expand**: 宏展开调试
- **cargo-audit**: 安全漏洞审计
- **cargo-outdated**: 依赖更新检查

---

## 🚀 快速开始

### 1️⃣ 应用配置

```bash
cd /etc/nixos
home-manager switch
```

或使用别名：
```bash
hm-switch  # 如果已配置
```

### 2️⃣ 初始化 Rust 工具链

首次使用后，设置默认工具链：

```bash
# 查看可用工具链
rustup show

# 安装稳定版（如果未自动安装）
rustup install stable

# 设置默认工具链
rustup default stable

# 验证安装
rustc --version
cargo --version
```

### 3️⃣ 创建第一个 Tauri 项目

使用内置的快捷命令：

```bash
# 创建新的 Tauri 项目（Vue 3 + TypeScript 模板）
new-tauri-app my-tauri-app

# 进入项目目录
cd my-tauri-app

# 启动开发服务器
td  # 等同于 cargo tauri dev
```

或手动创建：

```bash
# 使用官方脚手架
npm create tauri-app@latest my-app -- --manager npm --template vue-ts

cd my-app
npm install

# 启动开发模式
npm run tauri dev
```

---

## 💡 常用命令速查

### Rust 开发
```bash
cr    # cargo run          - 运行项目
cb    # cargo build        - 构建项目
ct    # cargo test         - 运行测试
cc    # cargo check        - 检查代码（不生成二进制）
cf    # cargo fmt          - 格式化代码
cl    # cargo clippy       - Lint 检查
```

### Tauri 开发
```bash
td    # cargo tauri dev    - 启动开发服务器（热重载）
tb    # cargo tauri build  - 构建生产版本
```

### 工具链管理
```bash
rs    # rustup show        - 显示当前工具链信息
ru    # rustup update      - 更新所有工具链
ri    # rustup install     - 安装指定版本（如: ri nightly）
```

### 项目管理
```bash
# 创建 Rust 库项目
new-rust-lib my-library

# 创建 Tauri 应用
new-tauri-app my-app
```

---

## 🎨 Naive UI 集成

Naive UI 是 Vue 3 组件库，需要在 Tauri 项目中通过 npm 安装：

### 在 Tauri + Vue 3 项目中使用

```bash
# 进入你的 Tauri 项目
cd my-tauri-app

# 安装 Naive UI 和 Vue
npm install naive-ui vue

# 或者使用 pnpm（推荐）
pnpm add naive-ui vue
```

### 示例：在 Vue 组件中使用

```vue
<script setup lang="ts">
import { NButton, NMessageProvider } from 'naive-ui'

const handleClick = () => {
  window.$message?.success('Hello from Naive UI!')
}
</script>

<template>
  <NMessageProvider>
    <NButton type="primary" @click="handleClick">
      点击我
    </NButton>
  </NMessageProvider>
</template>
```

---

## 🔧 高级配置

### 配置国内镜像源（加速依赖下载）

#### Cargo 镜像源

编辑 `~/.cargo/config.toml`：

```toml
[source.crates-io]
replace-with = 'ustc'

[source.ustc]
registry = "git://mirrors.ustc.edu.cn/crates.io-index"

# 如果处于 IPv6 环境，使用 https
# [source.ustc]
# registry = "https://mirrors.ustc.edu.cn/crates.io-index"
```

#### npm 镜像源

```bash
# 设置淘宝镜像
npm config set registry https://registry.npmmirror.com

# 验证配置
npm config get registry
```

### 多版本 Rust 工具链

```bash
# 安装 nightly 版本
rustup install nightly

# 为特定项目设置 nightly
cd my-project
rustup override set nightly

# 查看项目的工具链
rustup show

# 取消项目级别的覆盖
rustup override unset
```

### Tauri 构建优化

编辑 `src-tauri/tauri.conf.json`：

```json
{
  "build": {
    "beforeDevCommand": "npm run dev",
    "beforeBuildCommand": "npm run build",
    "devUrl": "http://localhost:1420",
    "distDir": "../dist"
  },
  "bundle": {
    "active": true,
    "targets": "all",
    "icon": [
      "icons/32x32.png",
      "icons/128x128.png",
      "icons/128x128@2x.png",
      "icons/icon.icns",
      "icons/icon.ico"
    ]
  }
}
```

---

## 🐛 故障排查

### 问题 1: Tauri 构建失败 - WebKitGTK 缺失

**症状**:
```
error: failed to run custom build command for `webkit2gtk-sys`
```

**解决**:
```bash
# 确认 webkitgtk 已安装
nix search nixpkgs webkitgtk

# 重新应用 Home Manager 配置
home-manager switch

# 重启终端或执行
source ~/.profile
```

### 问题 2: Node.js 版本不兼容

**症状**:
```
Error: Tauri requires Node.js >= 18
```

**解决**:
```bash
# 检查当前 Node.js 版本
node --version

# 如果需要其他版本，可以临时切换
nix shell nixpkgs#nodejs_18
```

### 问题 3: cargo-tauri 命令未找到

**症状**:
```
error: no such subcommand: `tauri`
```

**解决**:
```bash
# 确认 cargo-tauri 已安装
which cargo-tauri

# 如果没有，重新构建
home-manager switch

# 刷新 Cargo bin 路径
source ~/.profile
# 或
hash -r
```

### 问题 4: 系统托盘图标不显示

**症状**: Tauri 应用的系统托盘图标缺失

**解决**:
```bash
# 确认 libayatana-appindicator 已安装
nix search nixpkgs libayatana-appindicator

# KDE Plasma 可能需要额外配置
# 确保系统托盘小程序已添加到面板
```

### 问题 5: 热重载不工作

**症状**: 修改前端代码后，Tauri 窗口不自动刷新

**解决**:
```bash
# 确保使用的是 dev 模式而非 build
cargo tauri dev  # ✅ 正确
cargo tauri build # ❌ 这是生产构建

# 检查 Vite/Webpack 配置
# 确保 devServer 配置正确
```

---

## 📚 学习资源

### 官方文档
- [Rust Book](https://doc.rust-lang.org/book/)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
- [Tauri v2 Docs](https://v2.tauri.app/)
- [Naive UI Docs](https://www.naiveui.com/)

### 社区资源
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Tauri Awesome](https://github.com/tauri-apps/awesome-tauri)
- [Naive UI GitHub](https://github.com/tusen-ai/naive-ui)

### 示例项目
- [Tauri Examples](https://github.com/tauri-apps/tauri/tree/dev/examples)
- [Tauri + Vue 3 Template](https://github.com/tauri-apps/create-tauri-app)

---

## 🎯 最佳实践

### 1. 项目结构建议

```
my-tauri-app/
├── src-tauri/           # Rust 后端代码
│   ├── Cargo.toml
│   ├── src/
│   │   └── main.rs
│   └── tauri.conf.json
├── src/                 # 前端源码（Vue/React/Svelte）
│   ├── App.vue
│   └── main.ts
├── package.json
└── vite.config.ts
```

### 2. 开发工作流

```bash
# 1. 启动开发服务器（保持运行）
td

# 2. 在另一个终端进行 Rust 开发
cc      # 快速检查代码
cl      # Lint 检查
cb      # 构建测试

# 3. 提交前清理
cf      # 格式化代码
cl      # 修复 lint 问题
ct      # 运行测试
```

### 3. 性能优化

- **开发模式**: 使用 `cargo tauri dev` 享受热重载
- **生产构建**: 使用 `cargo tauri build --release`
- **增量编译**: Cargo 默认启用，无需额外配置
- **并行编译**: 设置 `CARGO_BUILD_JOBS=$(nproc)` 利用多核

### 4. 调试技巧

```bash
# 查看详细编译信息
cargo build -vv

# 展开宏查看生成的代码
cargo expand > expanded.rs

# 审计依赖安全性
cargo audit

# 检查过时的依赖
cargo outdated
```

---

<div align="center">

**Happy Coding with Rust + Tauri! 🦀✨**

</div>
