# 🚀 NixOS 系统配置 - 模块化架构

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Home Manager](https://img.shields.io/badge/Home_Manager-Integrated-purple?style=for-the-badge&logo=nix)

**清晰的模块化设计 • 手动硬件选择 • 声明式配置管理**

[📋 快速开始](#-快速开始) • [🏗️ 架构说明](#️-架构说明) • [🔧 常用命令](#-常用命令) • [📁 目录结构](#-目录结构)

</div>

---

## 🎯 核心特性

### ⚡ 设计理念

- ✅ **模块化清晰**: 硬件、网络、字体、存储等功能独立成模块
- ✅ **职责分离**: 系统级配置与用户级配置严格区分
- ✅ **无重复配置**: 所有配置项只在单一模块中定义，避免冲突
- ✅ **简单直接**: 放弃动态检测,采用手动导入路径
- ✅ **可重现**: Flakes 锁定依赖,确保构建一致性
- ✅ **性能优化**: earlyoom OOM 防护, USB 稳定性优化, SSD TRIM

### 📊 配置分层

| 层级 | 位置 | 职责 |
|------|------|------|
| **系统级** | [`configuration.nix`](configuration.nix) | 硬件驱动、系统服务、桌面环境安装 |
| **用户级** | [`home/`](home/) | 主题、字体、快捷键、应用配置 |
| **硬件模块** | [`modules/hardware/`](modules/hardware/) | CPU/GPU 特定优化 |
| **功能模块** | [`modules/network/`](modules/network/), [`modules/fonts/`](modules/fonts/), [`modules/storage/`](modules/storage/) | 网络、字体、存储等通用功能 |
| **固件模块** | [`modules/hardware/firmware.nix`](modules/hardware/firmware.nix) | 统一固件管理 |
| **特殊配置** | [`configs/`](configs/) | 可选的特殊应用场景配置 |

---

## 📋 快速开始

### 当前配置

| 项目 | 值 |
|------|-----|
| **系统版本** | NixOS 26.05 (Unstable) |
| **桌面环境** | KDE Plasma 6 (Wayland) |
| **CPU** | AMD Ryzen 5 5600 |
| **GPU** | AMD Radeon RX 6600 XT |
| **Shell** | Fish |
| **输入法** | Fcitx5 + Rime |
| **浏览器** | Floorp (Firefox Fork) |
| **编辑器** | VSCode + Vim |
| **终端** | Alacritty + Zellij |

### 首次部署

```
# 1. 克隆配置
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 生成硬件配置
nixos-generate-config --no-filesystems --root /

# 3. 编辑 configuration.nix 匹配硬件
#    修改 imports 中的 CPU/GPU 模块路径

# 4. 构建系统
sudo nixos-rebuild switch --flake .#nixos

# 5. 设置用户密码
passwd zhangchongjie
```

---

## 🏗️ 架构说明

### 配置分层原则

#### 系统级配置 ([`configuration.nix`](configuration.nix))

负责**全局基础设施**:
- 硬件驱动 (CPU/GPU/外设)
- 系统服务 (NetworkManager, PipeWire, SDDM)
- 桌面环境安装 (KDE Plasma 6)
- 网络基础设施 (防火墙、DNS、Avahi) - [`modules/network/default.nix`](modules/network/default.nix)
- 无线设备 (WiFi、蓝牙) - [`modules/network/wifi-bluetooth.nix`](modules/network/wifi-bluetooth.nix)
- 字体包安装
- 存储优化 (SSD TRIM、内核参数)
- OOM 防护 (earlyoom)
- Flatpak 集成

#### 用户级配置 ([`home/`](home/))

负责**个性化设置**:
- 主题和外观 ([`home/kde.nix`](home/kde.nix))
- Shell 配置 ([`home/fish.nix`](home/fish.nix))
- 编辑器配置 ([`home/vim.nix`](home/vim.nix), VSCode)
- 开发工具 (Git, direnv, Zellij)
- 环境变量和快捷键
- 应用配置 (Alacritty, Floorp, Lutris)

#### 特殊配置 ([`configs/`](configs/))

包含**可选的特殊应用场景配置**:
- MPD DSD音频播放配置 ([`configs/mpd-dsd.nix`](configs/mpd-dsd.nix))

### 模块化示例

```
# configuration.nix - 系统级
imports = [
  ./hardware-configuration.nix       # 设备特定(不提交Git)
  ./modules/hardware/cpu/ryzen-5600.nix   # CPU优化
  ./modules/hardware/gpu/rx-6600xt.nix      # GPU驱动
  ./modules/network/default.nix           # 网络配置
  ./modules/fonts/default.nix             # 字体配置
  ./modules/storage/ssd.nix               # SSD存储优化
];

# home/kde.nix - 用户级
xdg.configFile."kdeglobals" = { ... };  # KDE主题
home.sessionVariables = { ... };         # 环境变量
```

---

## 🔧 常用命令

### 系统重建

``fish
# 推荐: 使用 Fish 别名(已配置国内镜像源)
rebuild-flake

# 或完整命令
sudo -E nixos-rebuild switch --flake .#nixos

# 测试模式(不创建永久链接)
sudo nixos-rebuild test --flake .#nixos
```

### 更新依赖

```fish
# 更新 flake.lock 并重建(需要网络)
rebuild-update

# 仅清理旧世代
gc  # sudo nix-collect-garbage -d
```

### 离线重建

``fish
# 无网络时使用已缓存的包
rebuild-offline
```

### 其他实用命令

``fish
ll          # ls -la
c           # clear
s           # sudo
sk          # sudo killall -9
hm-switch   # home-manager switch (单独使用)
```

---

## 📁 目录结构

```
/etc/nixos/
├── configuration.nix              # 系统主配置 ⭐
├── hardware-configuration.nix     # 硬件配置(自动生成,不提交Git)
├── flake.nix                      # Flakes入口(简化版)
├── flake.lock                     # 依赖锁定文件
│
├── modules/
│   ├── fonts/                     # 字体配置模块
│   │   └── default.nix            # 字体包和渲染优化
│   │
│   ├── hardware/                  # 硬件相关模块
│   │   ├── cpu/                   # CPU特定优化
│   │   │   ├── ryzen-1600x.nix    # Ryzen 1600X配置
│   │   │   ├── ryzen-2600.nix     # Ryzen 2600配置  
│   │   │   ├── ryzen-3600.nix     # Ryzen 3600配置
│   │   │   └── ryzen-5600.nix     # Ryzen 5600配置
│   │   │
│   │   ├── gpu/                   # GPU特定优化
│   │   │   ├── r9-370.nix         # R9 370配置
│   │   │   ├── rx-5500xt.nix      # RX 5500 XT配置
│   │   │   └── rx-6600xt.nix      # RX 6600 XT配置
│   │   │
│   │   └── firmware.nix           # 统一固件管理模块
│   │
│   ├── network/                   # 网络功能模块
│   │   ├── default.nix            # 网络基础设施(防火墙、DNS、Avahi)
│   │   └── wifi-bluetooth.nix     # WiFi和蓝牙无线设备配置
│   │
│   └── storage/                   # 存储优化模块
│       └── ssd.nix                # SSD专用优化配置

│
├── home/                          # Home Manager用户配置
│   ├── default.nix                # HM入口
│   ├── fish.nix                   # Fish Shell
│   ├── git.nix                    # Git配置
│   ├── kde.nix                    # KDE个性化(主题/快捷键)
│   ├── alacritty.nix              # 终端模拟器
│   ├── vim.nix                    # Vim编辑器
│   ├── direnv.nix                 # 环境变量管理
│   └── zellij.nix                 # Terminal复用器
│
├── configs/                       # 特殊场景配置
│   └── mpd-dsd.nix                # MPD DSD音频播放配置
│
├── scripts/                       # 实用脚本
│   ├── start-clash-tun.sh         # Clash TUN启动
│   └── check-clash-tun.sh         # TUN状态检查
│
└── README.md                      # 本文档
```

---

## 🔑 关键设计决策

### 1. 为什么不用动态硬件检测?

**问题**: Flakes 动态扫描导致配置不透明,难以调试  
**解决**: 在 `configuration.nix` 中显式列出导入路径  
**优势**: 一目了然,修改即生效

### 2. 为什么系统和用户配置分离?

**系统级** (`configuration.nix`): "这台电脑运行什么服务"  
**用户级** (`home/`): "这个用户喜欢什么样的界面"  

**优势**:
- 支持多用户场景
- 配置职责清晰
- 符合 NixOS 最佳实践

### 3. 为什么不继续拆分模块?

当前模块化程度已足够:
- 配置文件约 400 行,复杂度可控
- 过度拆分会增加维护成本
- 遵循"**能跑就别动**"原则

### 4. 浏览器选择策略

- **Floorp** (Firefox Fork): 作为默认浏览器,通过 `programs.firefox.enable = false` 禁用原生 Firefox
- **MIME 关联**: 在 [`home/default.nix`](home/default.nix) 中声明式配置 Web 协议处理
- **Wayland 支持**: 通过 `MOZ_ENABLE_WAYLAND=1` 启用原生 Wayland 渲染

### 5. OOM 防护机制

- **earlyoom**: 用户空间 OOM 守护进程,在内存低于 5% 时主动终止进程
- **优势**: 避免系统完全死机,保留最后响应能力
- **配置**: 在 [`configuration.nix`](configuration.nix) 中声明,针对 Nix 构建场景优化

### 6. 固件统一管理

- **集中管理**: 创建专门的 [`modules/hardware/firmware.nix`](modules/hardware/firmware.nix) 模块
- **避免重复**: 从GPU模块和其他地方移除重复的固件配置
- **单一来源**: 所有固件相关配置只在固件模块中定义
- **易于维护**: 固件更新只需修改一个文件

### 7. 配置去重原则

- **内核参数**: USB稳定性参数移到CPU模块，GPU稳定性参数移到GPU模块，内存优化参数移到存储模块
- **蓝牙配置**: 从CPU模块移除，统一在无线模块中管理
- **主配置精简**: `configuration.nix` 只负责模块导入，不包含具体配置细节
- **职责明确**: 每个模块只负责其特定领域的配置

### 7. 网络模块职责划分

**基础设施层** ([`modules/network/default.nix`](modules/network/default.nix)):
- 防火墙配置(包括 Clash TUN 信任接口)
- DNS 解析服务(systemd-resolved)
- mDNS 服务(Avahi)
- Linux 网络性能优化参数

**无线设备层** ([`modules/network/wifi-bluetooth.nix`](modules/network/wifi-bluetooth.nix)):
- WiFi 后端配置(iwd/wpa_supplicant)
- 蓝牙协议栈和 Blueman 管理器
- 无线工具包(iw, wirelesstools)

**优势**:
- 有线/无线网络共用同一套防火墙和 DNS 基础设施
- 无线设备配置独立,便于在不同硬件间切换
- 避免配置重复和冲突

---

## ⚠️ 注意事项

### 硬件切换

1. 修改 [`configuration.nix`](configuration.nix) 中的 CPU/GPU 导入路径
2. 执行 `rebuild-flake`
3. **建议重启**以确保内核固件正确加载

### 网络问题

若遇到 GitHub 连接失败:
```
# 启动 Clash TUN 模式
sudo clash-tun
sleep 5

# 再执行重建
rebuild-flake
```

### Git 工作区

- `hardware-configuration.nix` 不提交到 Git(设备特定)
- 其他配置文件可以安全提交
- 多人协作时注意 `configuration.nix` 冲突

### 性能优化

- **USB 稳定性**: 禁用自动挂起,增加 USBFS 内存
- **SSD 优化**: 每周 TRIM, Swappiness=1, 专用存储内核参数
- **内存保护**: earlyoom 在 5% 阈值触发,防止 OOM 死机
- **并行构建**: `max-jobs = "auto"` 自动利用所有 CPU 核心

---

## 📚 参考资料

- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [Nix 配置选项搜索](https://search.nixos.org/options)
- [Nixpkgs 软件包搜索](https://search.nixos.org/packages)
- [Home Manager 文档](https://github.com/nix-community/home-manager)
- [NixOS Wiki - Fonts](https://wiki.nixos.org/wiki/Fonts)
- [KDE Plasma 6 文档](https://docs.kde.org/stable5/en/plasma-desktop/plasma-desktop/)

---

<div align="center">

**Made with ❤️ using NixOS • 简单就是美**

[![Built with Nix](https://img.shields.io/static/v1?label=Built%20with&message=Nix&color=5277C6&style=for-the-badge&logo=nixos)](https://nixos.org)

</div>