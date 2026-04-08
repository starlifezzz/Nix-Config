# 🚀 NixOS 系统配置 - 极简手动硬件选择

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Home Manager](https://img.shields.io/badge/Home_Manager-Integrated-purple?style=for-the-badge&logo=nix)

**简单直接的模块化 NixOS 配置 • 手动指定硬件 • 清晰可预测**

[📋 快速开始](#-快速开始) • [🔧 切换硬件](#-切换硬件配置) • [⚙️ 系统特性](#️-系统特性) • [📦 软件包](#-软件包) • [🔧 日常维护](#-日常维护) • [📁 目录结构](#-目录结构)

</div>

---

## 🎯 架构特点

### ⚡ 设计理念

**放弃 Flakes 的"伪动态"，回归简单直接！**

- ✅ **CPU/GPU 配置直接硬编码在 [`configuration.nix`](configuration.nix)**
- ✅ **`flake.nix` 只保留最简框架（用于 Home Manager）**
- ✅ **支持 `sudo nixos-rebuild switch --flake .#nixos` 构建**
- ✅ **配置清晰明了，一眼看出用的什么硬件**
- ✅ **多设备友好：每台设备独立生成 hardware-configuration.nix**

### 📊 架构对比

| 之前 (复杂 Flakes) | 现在 (简单直接) |
|-------------------|----------------|
| 动态扫描所有 `.nix` 文件 | 直接在 `imports` 中写死路径 |
| 生成所有硬件组合配置 | 只有唯一配置 `.#nixos` |
| 需要环境变量或默认值 | 无需任何隐式逻辑 |
| 修改后需重建多个配置 | 修改即生效 |

---

## 📋 快速开始

### 当前配置

| 项目 | 值 |
|------|-----|
| **系统版本** | NixOS 26.05 (Unstable) |
| **桌面环境** | KDE Plasma 6 (Wayland 原生) |
| **显示管理器** | SDDM |
| **内核** | Linux Latest (最新稳定版) |
| **文件系统** | BTRFS |
| **默认 Shell** | Fish |
| **时区** | Asia/Shanghai |
| **语言** | zh_CN.UTF-8 |
| **输入法** | Fcitx5 + Rime |

### 当前硬件配置

**CPU**: AMD Ryzen 5 2600  
**GPU**: AMD Radeon RX 5500

### 首次部署

```bash
# 1. 克隆配置到 /etc/nixos
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 生成当前设备的 hardware-configuration.nix
nixos-generate-config --no-filesystems --root /

# 3. 构建并切换
sudo nixos-rebuild switch --flake .#nixos

# 4. 设置用户密码
sudo passwd zhangchongjie
```

---

## 🔧 切换硬件配置

### 步骤超简单

#### 1️⃣ 编辑 [`configuration.nix`](configuration.nix)

找到 `imports` 部分（第 16-20 行）：

```nix
imports =
  [
    # 硬件配置（设备特定，不提交到 Git）
    ./hardware-configuration.nix
    
    # ═══════════════════════════════════════════════════════════
    # ✅ 手动指定 CPU 和 GPU 配置文件
    # 修改这里来切换硬件配置
    # ═══════════════════════════════════════════════════════════
    ./modules/hardware/cpu/ryzen-2600.nix   # ← 改这里！
    ./modules/hardware/gpu/rx-5500.nix      # ← 改这里！
  ];
```

#### 2️⃣ 修改为想要的硬件

**CPU 选项**（`modules/hardware/cpu/`）：
- `./modules/hardware/cpu/ryzen-1600x.nix`
- `./modules/hardware/cpu/ryzen-2600.nix` ← 当前使用
- `./modules/hardware/cpu/ryzen-3600.nix`

**GPU 选项**（`modules/hardware/gpu/`）：
- `./modules/hardware/gpu/r9-370.nix`
- `./modules/hardware/gpu/rx-5500.nix` ← 当前使用
- `./modules/hardware/gpu/rx-6600xt.nix`

#### 3️⃣ 执行构建

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

或使用 Fish Shell 别名：
```fish
rebuild-flake  # 已配置国内镜像源
```

#### 4️⃣ 重启系统（建议）

```bash
reboot
```

### ⚡ 架构优势

**✅ 直接了当**: 配置文件路径就是硬件型号，一目了然  
**✅ 无需判断**: 移除了所有 `lib.mkIf` 条件判断  
**✅ 即改即用**: 修改 imports 后立即生效  
**✅ 清晰透明**: 没有隐式逻辑或动态检测

### 💡 示例：切换到 Ryzen 3600 + RX 6600XT

**Step 1**: 编辑 `configuration.nix`
```diff
  imports =
    [
      ./hardware-configuration.nix
      # ... 其他配置 ...
-     ./modules/hardware/cpu/ryzen-2600.nix
+     ./modules/hardware/cpu/ryzen-3600.nix
-     ./modules/hardware/gpu/rx-5500.nix
+     ./modules/hardware/gpu/rx-6600xt.nix
    ];
```

**Step 2**: 构建
```bash
sudo nixos-rebuild switch --flake .#nixos
```

**Step 3**: 重启
```bash
reboot
```

**完成！** 🎉

---

## ⚙️ 系统特性

### 核心服务

#### 桌面环境
- **KDE Plasma 6**: 最新 Wayland 桌面体验
- **SDDM**: 显示管理器
- **Fcitx5**: 中文输入法（Rime 引擎）

#### 网络配置
- **防火墙**: 启用状态，信任 Clash TUN 接口
- **DNS**: 119.29.29.29 (腾讯), 223.5.5.5 (阿里)
- **Clash Verge Rev**: TUN 模式代理客户端

#### 性能优化
- **内核参数**:
  ```nix
  usbcore.autosuspend=-1       # USB 稳定性
  usbcore.usbfs_memory_mb=1024 # USBFS 内存优化
  ```
- **内存管理**: Swappiness = 1 (最小化 swap)
- **BTRFS**: 自动碎片整理 + 定期 scrub

### 安全特性

- **Sudo**: Wheel 组需密码
- **防火墙**: 默认拒绝，按需开放
- **TUN 模块**: 加载 (Clash Verge Rev)
- **网络管理权限**: netadmin 组

#### 外设支持

- **游戏手柄**: Xbox/北通鲲鹏 20（1000Hz 高回报率）
- **输入法**: Fcitx5 + Rime 中文输入
- **字体**: Noto + 思源 + 霞鹜文楷完整中文字体

---

## 🎮 游戏手柄配置

### 已支持设备

| 设备 | 模式 | 回报率 | 状态 |
|------|------|--------|------|
| **Xbox Series X|S** | Xbox | 1000Hz | ✅ 原生支持 |
| **Xbox One** | Xbox | 1000Hz | ✅ 原生支持 |
| **Xbox 360** | Xbox | 125Hz | ✅ 原生支持 |
| **北通鲲鹏 20** | Xbox (强制) | 1000Hz | ✅ 特殊优化 |
| **其他第三方** | Xbox 兼容 | 自动 | ✅ 通用支持 |

### 北通鲲鹏 20 特别优化

**问题**：默认被识别为 Switch 手柄，无法使用 1000Hz 高回报率  
**解决**：通过 udev 规则强制切换到 Xbox 模式

**配置位置**：[`modules/hardware/peripherals/gamepad.nix`](modules/hardware/peripherals/gamepad.nix)

**核心功能**：
- ✅ 强制 xpad 驱动绑定（Xbox 模式）
- ✅ 解除 hid-nintendo 驱动（Switch 模式）
- ✅ 设置 USB 轮询间隔 1ms（1000Hz）
- ✅ Steam Input 集成
- ✅ 手柄测试工具（jstest-gtk）

### 部署与验证

```bash
# 1. 应用配置
sudo nixos-rebuild switch --flake .#nixos

# 2. 重启系统（必需！）
reboot

# 3. 验证手柄模式
lsusb | grep -i betop
cat /proc/bus/input/devices | grep -A 10 -i betop

# 4. 测试手柄
jstest-gtk
```

### 故障排查

**仍识别为 Switch 控制器**：
```bash
sudo modprobe -r hid-nintendo        # 卸载 Switch 驱动
sudo udevadm control --reload-rules  # 重载 udev 规则
sudo udevadm trigger                 # 触发规则
# 重新插拔手柄
```

**xpad 驱动未加载**：
```bash
lsmod | grep xpad           # 检查驱动状态
sudo modprobe xpad          # 手动加载
```

**权限不足**：
```bash
groups zhangchongjie | grep input  # 确认在 input 组
newgrp input                        # 临时切换
# 或重新登录
```

详细文档：[`modules/hardware/peripherals/gamepad.nix`](modules/hardware/peripherals/gamepad.nix)

---

## 📦 软件包

### 开发工具

**系统级**:
- **VSCode** (unstable 版本) - 主代码编辑器
- **Git** - 版本控制
- **Vim** - 文本编辑器
- **Alacritty** - GPU 加速终端
- **Zellij** - Terminal 多路复用器
- **direnv** - 环境变量管理

**用户级 (Home Manager)**:
- **JetBrains Mono** - 编程字体
- **Fira Code** - 连字编程字体
- **Rust 工具链** - rustup, cargo-tauri, Node.js 20 LTS（详见 [Rust 开发指南](home/RUST_DEV_GUIDE.md)）

### Rust + Tauri 开发环境 🆕

专门配置的 Rust 桌面应用开发环境：
- **rustup**: Rust 工具链管理器
- **cargo-tauri**: Tauri CLI v2.9.6
- **Node.js 20 LTS**: 前端开发必需
- **WebKitGTK**: Linux 平台渲染引擎
- **辅助工具**: cargo-watch, cargo-expand, cargo-audit, cargo-outdated

详细使用文档：[`home/RUST_DEV_GUIDE.md`](home/RUST_DEV_GUIDE.md)

### 网络应用

- **Firefox** - 浏览器 (Wayland 原生)
- **Clash Verge Rev** - 代理客户端 (TUN 模式)
- **KDE Connect** - 设备互联

### 系统工具

- **Fastfetch** - 系统信息显示
- **Timeshift** - 系统备份
- **BleachBit** - 系统清理
- **Flatpak** - 通用包管理
- **FFmpeg (Full)** - 音视频处理
- **Node.js** - JavaScript 运行时 (完整版，支持 MCP Server)

---

## 👤 用户配置

### 主用户：zhangchongjie

- **用户组**: networkmanager, wheel, flatpak, video, render, input, netadmin
- **默认 Shell**: Fish
- **Sudo 权限**: 需要密码

### Fish Shell 配置

#### 实用别名

```fish
ll = "ls -la"
la = "ls -A"
rebuild = "sudo -E nixos-rebuild switch"
rebuild-test = "sudo -E nixos-rebuild test"
gc = "sudo nix-collect-garbage -d"
optimise = "sudo nix-store --optimise"
c = "clear"
s = "sudo"
update = "sudo nixos-rebuild switch"
nrs = "sudo nixos-rebuild switch"
rebuild-flake = "sudo nixos-rebuild switch --flake .#nixos"
rebuild-offline = "sudo nixos-rebuild switch --offline"
```

#### 重建命令（推荐）

```fish
# 使用国内镜像源重建
rebuild-flake

# 离线重建
rebuild-offline
```

### Git 配置

- **用户名**: zhangchongjie
- **邮箱**: 778280151@qq.com
- **默认分支**: main
- **编辑器**: Vim
- **推送策略**: Simple
- **拉取策略**: Rebase
- **自动修剪**: 启用

---

## 🌐 网络配置

### 防火墙

- **状态**: 启用
- **允许 Ping**: 是
- **信任接口**: Mihomo, Meta, clash0, utun* (Clash TUN 模式)
- **开放端口**:
  - UDP/TCP: 1714-1764 (KDE Connect)

### 代理服务

- **Clash Verge Rev**: 主代理客户端
  - TUN 模式：启动脚本自动配置
  - HTTP 代理：http://127.0.0.1:7897
  - SOCKS5 代理：socks5://127.0.0.1:7891

### DNS

- **DNS 服务器**: 119.29.29.29 (腾讯 DNSPod), 223.5.5.5 (阿里 DNS)
- **DNSSEC**: 禁用
- **Avahi/mDNS**: 启用 (IPv4)

---

## 🎮 Clash TUN 模式

### 启动 TUN 模式

```bash
# 启动（需要 sudo）
sudo clash-tun
# 或
sudo ./scripts/start-clash-tun.sh
```

### 检查 TUN 状态

```bash
# 检查 TUN 接口
ip link show Mihomo

# 检查进程
ps aux | grep verge-mihomo

# 使用检查脚本
check-clash
```

### 停止 TUN 模式

```bash
sudo pkill -f verge-mihomo
```

### ⚠️ 注意事项

- TUN 设备在每次重启后需要重新运行启动脚本
- 确保 `netadmin` 用户组已生效（需重新登录）
- Clash Verge Rev GUI 会自动生成配置文件

---

## 📁 目录结构

```
/etc/nixos/
├── configuration.nix              # 系统主配置 ⭐ (直接导入 CPU/GPU 模块)
├── hardware-configuration.nix     # 硬件配置 (BTRFS, 自动生成，不提交到 Git)
├── flake.nix                      # Flakes 入口 (简化版，仅用于 Home Manager)
├── flake.lock                     # 版本锁定文件
├── .gitignore                     # Git 忽略规则
│
├── home/                          # Home Manager 用户配置
│   ├── default.nix               # Home Manager 入口
│   ├── fish.nix                  # Fish Shell 配置
│   ├── git.nix                   # Git 配置
│   ├── kde.nix                   # KDE Plasma 详细配置
│   ├── alacritty.nix             # Alacritty 终端配置
│   ├── vim.nix                   # Vim 配置
│   ├── direnv.nix                # direnv 配置
│   ├── zellij.nix                # Zellij 多路复用器配置
│   ├── rust-dev.nix              # 🆕 Rust + Tauri + Naive UI 开发环境
│   └── RUST_DEV_GUIDE.md         # 🆕 Rust 开发环境使用指南
│
├── modules/                       # 自定义配置模块
│   ├── hardware/                 # 硬件相关配置
│   │   ├── cpu/                  # CPU 特定配置
│   │   │   ├── ryzen-1600x.nix
│   │   │   ├── ryzen-2600.nix    # ← 当前使用
│   │   │   └── ryzen-3600.nix
│   │   ├── gpu/                  # GPU 特定配置
│   │   │   ├── r9-370.nix
│   │   │   ├── rx-5500.nix       # ← 当前使用
│   │   │   └── rx-6600xt.nix
│   │   └── peripherals/          # 外设配置（手柄、键盘、鼠标等）
│   │       └── gamepad.nix       # 游戏手柄通用配置 ⭐
│   ├── network/                  # 🆕 网络配置模块
│   │   └── default.nix           # 防火墙、DNS、Avahi 等网络设置
│   └── fonts/                    # 🆕 字体配置模块
│       └── default.nix           # 字体包、渲染优化、Flatpak 字体访问
│
├── scripts/                       # 实用脚本
│   ├── start-clash-tun.sh        # Clash TUN 模式启动
│   └── check-clash-tun.sh        # TUN 状态检查
│
├── QUICK_REFERENCE.md             # 快速参考手册
└── README.md                      # 本文档
```

---

## 💡 架构演进

### 最新版本 (2026-03-30)

**✅ 完全移除条件判断**: 
- 删除了 `detection.nix` 模块
- 移除了所有 `lib.mkIf` 条件判断
- 不再需要 `hardware.*.manualModel` 中间变量

**🎯 极简架构**:
```
configuration.nix (imports) → 硬件模块 (直接应用配置)
```

**优势**:
- 导入即生效，不会遗漏
- 配置透明，一目了然
- 维护成本最低

---

## 🔧 日常维护

### 系统重建（推荐工作流）

```bash
cd /etc/nixos

# 方式 1: 使用 Fish alias (推荐)
rebuild-flake

# 方式 2: 使用简短别名
nrs --flake .#nixos

# 方式 3: 完整命令
sudo nixos-rebuild switch --flake .#nixos
```

### 更新依赖（需网络）

```bash
# 更新 flake inputs (每月/每季度执行)
nix flake update

# 更新 channel (可选)
sudo nix-channel --update
```

### 垃圾回收

```bash
# 清理旧世代
sudo nix-collect-garbage -d

# 或使用 alias
gc

# 优化存储
sudo nix-store --optimise
```

### 查看系统信息

```bash
fastfetch
```

### 验证当前硬件配置

```bash
# 查看导入的 CPU 配置
grep "cpu/" /etc/nixos/configuration.nix

# 查看导入的 GPU 配置
grep "gpu/" /etc/nixos/configuration.nix

# 查看当前配置的主机名
nix eval '.#nixos.config.networking.hostName'
```

### 系统回滚

```bash
# 回滚到上一代
sudo nixos-rebuild switch --rollback

# 查看可用世代
nixos-rebuild list-generations

# 回滚到特定世代
sudo nixos-rebuild switch --switch-generation <generation-number>
```

---

## ❗ 注意事项

### 首次启动

1. 确保 BIOS 中启用了 EFI 启动
2. 准备好网络连接 (有线优先)
3. 首次构建时间较长（约 30-60 分钟）
4. 首次启动后记得设置用户密码：
   ```bash
   sudo passwd zhangchongjie
   ```

### 硬件切换

- ✅ **修改 `configuration.nix` 后立即生效**
- ✅ 切换硬件配置后建议重启系统
- ✅ 不同硬件的 firmware 可能不同，请确保内核固件包完整
- ✅ 建议在 `/etc/nixos` 目录下执行重建命令

### Boot 分区保护

- 已配置 `configurationLimit = 10` 限制启动项数量
- 定期执行 `sudo nix-collect-garbage -d` 清理旧世代
- 使用 `bootctl list` 或 `df -h /boot` 定期检查空间

### Flatpak 使用

首次使用后添加远程仓库：
```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub
```

### 用户安全

- `netadmin` 用户组修改后需重新登录生效
- 防火墙已启用，按需开放端口

### 多设备部署

- `hardware-configuration.nix` 不提交到 Git
- 每台设备独立生成自己的硬件配置
- Git 仓库只保存通用配置
- 切换设备时只需修改 `configuration.nix` 中的 CPU/GPU 导入路径

---

## 🎯 设计原则

### 简单至上

1. **放弃"伪动态"**: 不再尝试在 Nix 代码中做运行时检测
2. **显式优于隐式**: 硬件配置一目了然
3. **修改即生效**: 无需理解复杂的 Flakes 求值机制

### 模块化架构

1. **硬件解耦**: CPU/GPU 配置完全分离
2. **职责分明**: 系统级 vs 用户级配置清晰
3. **类型安全**: 通过直接导入保证配置正确性

### 可维护性

1. **版本锁定**: flake.lock 确保可重复构建
2. **命名规范**: 标准化的文件名和路径
3. **文档齐全**: 每个配置都有清晰注释

---

## 📚 参考资料

- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [Nix 配置选项](https://search.nixos.org/options)
- [Nixpkgs 软件包搜索](https://search.nixos.org/packages)
- [Home Manager](https://github.com/nix-community/home-manager)
- [NixOS Hardware](https://github.com/NixOS/nixos-hardware)
- [KDE Plasma 6](https://kde.org/plasma-desktop)
- [Clash Verge Rev](https://github.com/clash-verge-rev/clash-verge-rev)

---

## 🛠️ 技术栈

- **基础系统**: NixOS 26.05 (Unstable)
- **配置管理**: Nix Flakes (简化版)
- **用户配置**: Home Manager (NixOS 集成模式)
- **桌面环境**: KDE Plasma 6
- **显示协议**: Wayland
- **硬件支持**: AMD Ryzen (1600X/2600/3600) + AMD Radeon (R9 370/RX 5500/RX 6600XT)
- **代理方案**: Clash Verge Rev (TUN 模式)

---

<div align="center">

**Made with ❤️ using NixOS • 简单就是美**

[![Built with Nix](https://img.shields.io/static/v1?label=Built%20with&message=Nix&color=5277C6&style=for-the-badge&logo=nixos)](https://nixos.org)

</div>

```
# NixOS 配置 - 手动硬件选择模式

## 📝 架构说明

本配置已移除 Flakes 的动态硬件检测，改为**手动指定 CPU 和 GPU 配置文件**，简单直接！

## 🔧 如何切换硬件配置

### 1. 编辑 `flake.nix`

打开 [`flake.nix`](flake.nix) 文件，修改第 18-19 行：

```nix
# ✅ 手动指定 CPU 和 GPU 配置文件
# 修改这里来切换硬件配置
cpuConfig = "ryzen-2600";  # 可选：ryzen-1600x, ryzen-2600, ryzen-3600
gpuConfig = "rx-5500";     # 可选：r9-370, rx-5500, rx-6600xt
```

### 2. 可用的硬件选项

**CPU 选项**（位于 `modules/hardware/cpu/`）：
- `ryzen-1600x`
- `ryzen-2600`
- `ryzen-3600`

**GPU 选项**（位于 `modules/hardware/gpu/`）：
- `r9-370`
- `rx-5500`
- `rx-5500xt`
- `rx-5700`
- `rx-5700-xt`
- `rx-6600-xt` / `rx-6600xt`

### 3. 构建并应用配置

```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

## ⚡ 快速切换示例

### 示例 1：从 Ryzen 2600 + RX 5500 切换到 Ryzen 3600 + RX 6600XT

1. 编辑 `flake.nix`：
   ```nix
   cpuConfig = "ryzen-3600";
   gpuConfig = "rx-6600xt";
   ```

2. 执行构建：
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

3. 重启系统（建议）：
   ```bash
   reboot
   ```

### 示例 2：临时测试另一套配置

如果想测试但不立即切换：
```bash
sudo nixos-rebuild test --flake .#nixos
```

这样下次重启后会回到旧配置。

## 📋 当前配置

查看当前生效的硬件配置：
```bash
nix eval '.#nixos.config.hardware.cpu.model'
nix eval '.#nixos.config.hardware.gpu.model'
```

## ❗ 注意事项

1. **必须指定有效的硬件名称**：如果文件名不存在，构建会失败
2. **建议重启**：切换硬件配置后最好重启，确保内核固件正确加载
3. **Lock 文件**：`flake.lock` 会锁定所有依赖版本，确保可复现性

## 🛠️ 添加新硬件支持

如果要支持新的 CPU/GPU：

1. 在对应目录创建配置文件：
   ```bash
   touch modules/hardware/cpu/new-cpu.nix
   touch modules/hardware/gpu/new-gpu.nix
   ```

2. 编写配置内容（参考现有文件）

3. 在 `flake.nix` 中添加新选项：
   ```nix
   cpuConfig = "new-cpu";
   gpuConfig = "new-gpu";
   ```

```
# NixOS 配置 - 极简手动硬件选择模式

## 🎯 架构说明

**已完全摆脱 Flakes 的复杂硬件选择逻辑！**

- ✅ **CPU/GPU 配置直接硬编码在 [`configuration.nix`](configuration.nix) 中**
- ✅ **`flake.nix` 只保留最简框架（用于 Home Manager）**
- ✅ **支持 `sudo nixos-rebuild switch` 直接构建**

---

## 🖥️ 多设备部署方案（优雅版）

### 📋 问题背景

如果你有多台设备（如 Ryzen 2600+RX5500, Ryzen 3600+RX6600XT），想要复用同一套配置，但不想每次都修改 Git 仓库，这个方案完美解决！

### ✅ 解决方案：`.gitignore` + 本地配置

#### 核心思路

1. **`hardware-configuration.nix` 不提交到 Git**
   - 每台设备生成自己的硬件配置文件
   - 包含分区 UUID、MAC 地址等设备特定信息
   - 通过 `.gitignore` 忽略，不会污染仓库

2. **CPU/GPU 配置在每台设备上独立修改**
   - 修改 [`configuration.nix`](configuration.nix) 中的导入路径
   - 改完后本地测试，确认无误后再提交

3. **Git 仓库只保存通用配置**
   - 所有设备共享的代码在仓库中
   - 设备特定的配置在本地

### 🔧 部署步骤

#### 设备 A：Ryzen 2600 + RX 5500

```bash
# 1. 克隆配置到 /etc/nixos
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 生成当前设备的 hardware-configuration.nix
nixos-generate-config --no-filesystems --root /

# 3. 编辑 configuration.nix，设置正确的 CPU/GPU
vim configuration.nix
# 修改第 16-17 行：
#   ./modules/hardware/cpu/ryzen-2600.nix
#   ./modules/hardware/gpu/rx-5500.nix

# 4. 构建并测试
sudo nixos-rebuild switch --flake .#nixos

# 5. 确认无误后，提交通用配置（可选）
git add configuration.nix  # 如果这次改动是通用的
git commit -m "feat: update configuration for Ryzen 2600 + RX 5500"
git push

# ⚠️ 注意：hardware-configuration.nix 不会被提交（已在 .gitignore 中）
```

#### 设备 B：Ryzen 3600 + RX 6600XT

```bash
# 1. 克隆配置（拉取设备 A 的提交）
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 生成当前设备的 hardware-configuration.nix
nixos-generate-config --no-filesystems --root /

# 3. 编辑 configuration.nix，修改为当前硬件
vim configuration.nix
# 修改第 16-17 行：
#   ./modules/hardware/cpu/ryzen-3600.nix
#   ./modules/hardware/gpu/rx-6600xt.nix

# 4. 构建并测试
sudo nixos-rebuild switch --flake .#nixos

# 5. （可选）如果这是通用更新，提交到仓库
git add configuration.nix
git commit -m "feat: switch to Ryzen 3600 + RX 6600XT"
git push
```

### 🔄 切换设备时的操作

当你把硬盘从设备 A 移到设备 B 时：

```bash
# 1. 切换到新配置的分支（如果你有多个分支）
git checkout ryzen-3600-rx6600xt

# 2. 或者直接修改 configuration.nix
vim configuration.nix
# 修改 CPU/GPU 导入路径

# 3. 重建系统
sudo nixos-rebuild switch --flake .#nixos

# 4. 重启
reboot
```

### 📦 Git 工作流建议

#### 方案 1：单分支 + 手动修改（推荐）

- **主分支**：保持一套默认配置（如 Ryzen 2600 + RX 5500）
- **切换设备**：手动修改 `configuration.nix` -> 重建 -> （可选）提交

**优点**：简单直接，适合 2-3 台设备  
**缺点**：每次切换需要手动修改

#### 方案 2：多分支（适合设备固定）

```bash
# 为每台设备创建分支
git checkout -b device-a-ryzen2600-rx5500
git checkout -b device-b-ryzen3600-rx6600xt

# 在每个分支中设置对应的 hardware-configuration.nix 和 CPU/GPU 配置
```

**优点**：每台设备配置清晰，切换只需 `git checkout`  
**缺点**：分支多了管理复杂

#### 方案 3：Git Submodule（高级玩家）

```bash
# 将 hardware-configuration.nix 放到单独的子模块
git submodule add <your-hardware-config-repo> local-hardware
```

**优点**：完全解耦，每台设备有自己的硬件配置仓库  
**缺点**：配置复杂，不适合新手

### 🛡️ 最佳实践

#### 1. 定期备份 hardware-configuration.nix

```bash
# 备份到安全位置
cp /etc/nixos/hardware-configuration.nix \
   ~/backups/hardware-configuration-$(hostname)-$(date +%Y%m%d).nix
```

#### 2. 使用注释标记设备特定配置

在 `configuration.nix` 中添加注释：

```nix
imports =
  [
    ./hardware-configuration.nix  # 此文件不提交到 Git（设备特定）
    
    # 当前设备：Ryzen 2600 + RX 5500
    # 切换设备时修改下面两行：
    ./modules/hardware/cpu/ryzen-2600.nix
    ./modules/hardware/gpu/rx-5500.nix
  ];
```

#### 3. 创建快速切换脚本（可选）

创建 `scripts/switch-hardware.sh`：

```bash
#!/usr/bin/env bash
set -e

CPU=$1
GPU=$2

if [ -z "$CPU" ] || [ -z "$GPU" ]; then
  echo "用法：$0 <cpu> <gpu>"
  echo "示例：$0 ryzen-2600 rx-5500"
  exit 1
fi

CONFIG_FILE="/etc/nixos/configuration.nix"

# 备份原文件
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# 替换 CPU 配置
sed -i "s|modules/hardware/cpu/.*\.nix|modules/hardware/cpu/${CPU}.nix|g" "$CONFIG_FILE"

# 替换 GPU 配置
sed -i "s|modules/hardware/gpu/.*\.nix|modules/hardware/gpu/${GPU}.nix|g" "$CONFIG_FILE"

echo "✅ 配置已切换到：${CPU} + ${GPU}"
echo "💡 执行以下命令应用更改："
echo "   sudo nixos-rebuild switch --flake .#nixos"
```

使用方法：
```bash
chmod +x scripts/switch-hardware.sh
./scripts/switch-hardware.sh ryzen-3600 rx-6600xt
```

### ⚠️ 注意事项

1. **`hardware-configuration.nix` 必须存在**
   - 虽然不提交到 Git，但重建时必须存在
   - 首次克隆后记得运行 `nixos-generate-config`

2. **切换硬件后建议重启**
   - 确保内核固件正确加载
   - 特别是 GPU 驱动

3. **Git 冲突处理**
   - 如果多人协作，注意 `configuration.nix` 的冲突
   - 建议在提交前 pull 最新代码

---

## 🔧 如何切换硬件配置

### 1. 编辑 [`configuration.nix`](configuration.nix) 第 16-17 行

找到 `imports` 部分，修改 CPU 和 GPU 配置文件路径：

```
imports =
  [
    # ... 其他配置 ...
    
    # ═══════════════════════════════════════════════════════════
    # ✅ 手动指定 CPU 和 GPU 配置文件
    # 修改这里来切换硬件配置
    # ═══════════════════════════════════════════════════════════
    ./modules/hardware/cpu/ryzen-2600.nix   # 改成你想要的 CPU
    ./modules/hardware/gpu/rx-5500.nix      # 改成你想要的 GPU
  ];
```

### 2. 可用的硬件选项

**CPU 选项**（位于 `modules/hardware/cpu/`）：
- `ryzen-1600x.nix`
- `ryzen-2600.nix`
- `ryzen-3600.nix`

**GPU 选项**（位于 `modules/hardware/gpu/`）：
- `r9-370.nix`
- `rx-5500.nix`
- `rx-5500xt.nix`
- `rx-5700.nix`
- `rx-5700-xt.nix`
- `rx-6600-xt.nix` / `rx-6600xt.nix`

### 3. 构建并应用配置

```
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

---

## ⚡ 快速切换示例

### 示例：从 Ryzen 2600 + RX 5500 切换到 Ryzen 3600 + RX 6600XT

1. **编辑 [`configuration.nix`](configuration.nix)**：
   ```nix
   imports =
     [
       # ... 其他配置保持不变 ...
       ./modules/hardware/cpu/ryzen-3600.nix   # ← 改这里
       ./modules/hardware/gpu/rx-6600xt.nix    # ← 改这里
     ];
   ```

2. **执行构建**：
   ```bash
   cd /etc/nixos
   sudo nixos-rebuild switch --flake .#nixos
   ```

3. **重启系统**（建议）：
   ```bash
   reboot
   ```

---

## 💡 Shell 别名（已配置）

你的 Fish Shell 已经有现成的别名：

```
# 使用 Flakes 重建（推荐）
rebuild-flake

# 或简短版本
nrs --flake .#nixos

# 完整命令
sudo nixos-rebuild switch --flake .#nixos
```

---

## 📋 当前配置

查看当前生效的硬件配置：
```
# 查看导入的 CPU 配置
grep "cpu/" /etc/nixos/configuration.nix

# 查看导入的 GPU 配置
grep "gpu/" /etc/nixos/configuration.nix
```

---

## ❗ 注意事项

1. **必须指定有效的文件路径**：如果 `.nix` 文件不存在，构建会失败
2. **建议重启**：切换硬件配置后最好重启，确保内核固件正确加载
3. **Lock 文件**：`flake.lock` 会锁定所有依赖版本，确保可复现性
4. **Home Manager**：仍然通过 Flakes 集成，建议使用 `--flake` 参数
5. **`hardware-configuration.nix`**：此文件不提交到 Git，每台设备独立生成

---

## 🛠️ 添加新硬件支持

如果要支持新的 CPU/GPU：

1. **创建配置文件**：
   ```bash
   touch modules/hardware/cpu/new-cpu.nix
   touch modules/hardware/gpu/new-gpu.nix
   ```

2. **编写配置内容**（参考现有文件）

3. **在 [`configuration.nix`](configuration.nix) 中添加导入**：
   ```nix
   imports = [
     # ...
     ./modules/hardware/cpu/new-cpu.nix
     ./modules/hardware/gpu/new-gpu.nix
   ];
   ```

---

## 📊 架构对比

### 之前（复杂 Flakes）
```
flake.nix → 动态扫描文件 → 生成所有组合 → 选择配置 → configuration.nix
```

### 现在（简单直接）
```
configuration.nix → 直接导入 CPU/GPU 文件 → 构建
```

**优点**：
- ✅ 配置清晰明了，一眼看出用的什么硬件
- ✅ 修改简单，只需改一个文件路径
- ✅ 不再跟 Flakes 的求值机制较劲
- ✅ 支持 `sudo nixos-rebuild switch --flake .#nixos` 直接构建
- ✅ **多设备友好：每台设备有自己的本地配置，不污染仓库**
