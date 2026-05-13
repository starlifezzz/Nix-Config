# 🚀 NixOS 系统配置 - 模块化架构

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Home Manager](https://img.shields.io/badge/Home_Manager-Integrated-purple?style=for-the-badge&logo=nix)

**模块化设计 • 声明式配置 • 可重现构建**

[📋 快速开始](#-快速开始) • [🏗️ 架构概览](#️-架构概览) • [📁 目录结构](#-目录结构) • [🔧 常用命令](#-常用命令)

</div>

---

## 📋 快速开始

### 系统环境

| 组件 | 版本/配置 |
|------|-----------|
| **系统** | NixOS 26.05 (Unstable) |
| **桌面环境** | KDE Plasma 6 (Wayland) |
| **Shell** | Fish |
| **终端复用器** | Zellij |
| **编辑器** | VSCode + Vim |

### 部署流程

```bash
# 1. 克隆配置到 /etc/nixos
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 生成硬件配置（不包含文件系统）
nixos-generate-config --no-filesystems --root /

# 3. 根据实际硬件修改 configuration.nix 中的导入路径
#    - CPU模块: ./modules/hardware/cpu/<cpu-model>.nix
#    - GPU模块: ./modules/hardware/gpu/<gpu-model>.nix

# 4. 构建并激活配置
sudo nixos-rebuild switch --flake .#nixos

# 5. 设置用户密码
passwd <username>
```

---

## 🏗️ 架构概览

### 配置分层

本配置采用清晰的三层架构：

| 层级 | 职责 | 位置 |
|------|------|------|
| **系统级** | 硬件驱动、系统服务、桌面环境 | [`configuration.nix`](configuration.nix) |
| **模块级** | 功能模块化配置 | [`modules/`](modules/) |
| **用户级** | 个性化设置、应用配置 | [`home/`](home/) |

### 设计原则

- **模块化清晰**: 功能独立成模块，职责单一
- **声明式配置**: 所有配置通过Nix表达式声明
- **无重复配置**: 配置项只在单一模块中定义
- **可重现构建**: Flakes锁定依赖版本
- **性能优化**: 包含earlyoom、SSD TRIM、USB稳定性等优化

---

## 📁 目录结构

```
/etc/nixos/
├── configuration.nix              # 系统主配置入口 ⭐
├── hardware-configuration.nix     # 硬件配置（自动生成，不提交Git）
├── flake.nix                      # Flakes入口
├── flake.lock                     # 依赖锁定文件
│
├── modules/                       # 功能模块目录
│   ├── fonts/                     # 字体配置
│   │   └── default.nix            # 字体包和渲染优化
│   │
│   ├── hardware/                  # 硬件相关模块
│   │   ├── cpu/                   # CPU特定优化
│   │   │   ├── ryzen-1600x.nix    # Ryzen 1600X配置
│   │   │   ├── ryzen-2600.nix     # Ryzen 2600配置  
│   │   │   ├── ryzen-3600.nix     # Ryzen 3600配置
│   │   │   └── ryzen-5600.nix     # Ryzen 5600配置
│   │   │
│   │   └── gpu/                   # GPU特定优化
│   │       ├── r9-370.nix         # R9 370配置
│   │       ├── rx-5500.nix        # RX 5500配置
│   │       ├── rx-5500xt.nix      # RX 5500 XT配置
│   │       └── rx-6600xt.nix      # RX 6600 XT配置
│   │
│   ├── network/                   # 网络功能模块
│   │   ├── default.nix            # 网络基础设施（防火墙、DNS、Avahi）
│   │   └── wifi-bluetooth.nix     # WiFi和蓝牙无线设备配置
│   │
│   └── storage/                   # 存储优化模块
│       └── ssd.nix                # SSD专用优化配置
│
├── home/                          # Home Manager用户配置
│   ├── default.nix                # HM入口和通用配置
│   ├── alacritty.nix              # 终端模拟器配置
│   ├── direnv.nix                 # 环境变量管理
│   ├── fish.nix                   # Fish Shell配置
│   ├── ghostty.nix                # Ghostty终端配置
│   ├── git.nix                    # Git配置
│   ├── kde.nix                    # KDE个性化配置
│   ├── vim.nix                    # Vim编辑器配置
│   └── zellij.nix                 # Terminal复用器配置
│
├── configs/                       # 特殊场景配置
│   └── mpd-dsd.nix                # MPD DSD音频播放配置
│
├── scripts/                       # 实用脚本
│   ├── start-clash-tun.sh         # Clash TUN启动脚本
│   └── check-clash-tun.sh         # TUN状态检查脚本
│
└── README.md                      # 本文档
```

---

## 🔧 常用命令

### 系统管理

```fish
# 系统重建（推荐使用Fish别名）
rebuild-flake

# 完整重建命令
sudo -E nixos-rebuild switch --flake .#nixos

# 测试模式（不创建永久世代）
sudo nixos-rebuild test --flake .#nixos
```

### 依赖更新

```fish
# 更新flake.lock并重建
rebuild-update

# 清理旧世代
gc  # 等价于 sudo nix-collect-garbage -d
```

### 离线操作

```fish
# 无网络时使用缓存包重建
rebuild-offline
```

### 实用别名

```fish
ll          # ls -la
c           # clear
s           # sudo
sk          # sudo killall -9
hm-switch   # home-manager switch
```

---

## 🔑 关键设计决策

### 1. 显式硬件配置

**问题**: 动态硬件检测导致配置不透明  
**方案**: 在 `configuration.nix` 中显式导入CPU/GPU模块  
**优势**: 配置清晰可见，易于维护和调试

### 2. 系统/用户配置分离

- **系统级**: 硬件驱动、系统服务、全局设置
- **用户级**: 主题、字体、快捷键、应用偏好

**优势**: 支持多用户，职责清晰，符合NixOS最佳实践

### 3. 网络模块分层

- **基础设施层** (`modules/network/default.nix`): 防火墙、DNS、mDNS
- **无线设备层** (`modules/network/wifi-bluetooth.nix`): WiFi、蓝牙配置

**优势**: 有线/无线共用基础设施，避免配置重复

### 4. 固件统一管理

所有固件配置集中在 `modules/hardware/firmware.nix`，避免在多个模块中重复定义。

### 5. 性能优化集成

- **内存保护**: earlyoom守护进程（5%内存阈值）
- **存储优化**: SSD TRIM、swappiness=1、专用内核参数
- **USB稳定性**: 禁用自动挂起、增加USBFS内存
- **构建性能**: 自动并行构建（max-jobs = "auto"）

---

## ⚠️ 注意事项

### 硬件切换

1. 修改 `configuration.nix` 中的CPU/GPU导入路径
2. 执行 `rebuild-flake`
3. **建议重启**以确保内核固件正确加载

### 网络代理

若遇到网络连接问题：
```bash
# 启动Clash TUN模式
sudo ./scripts/start-clash-tun.sh
sleep 5

# 再执行重建
rebuild-flake
```

### Git工作流

- `hardware-configuration.nix` 不提交到Git（设备特定）
- 其他配置文件可安全提交
- 多人协作时注意 `configuration.nix` 的合并冲突

---

## 📚 参考资料

- [NixOS 官方文档](https://nixos.org/manual/nixos/unstable/)
- [Nix 配置选项搜索](https://search.nixos.org/options)
- [Nixpkgs 软件包搜索](https://search.nixos.org/packages)
- [Home Manager 文档](https://nix-community.github.io/home-manager/unstable/)
- [KDE Plasma 6 文档](https://docs.kde.org/stable5/en/plasma-desktop/plasma-desktop/)

---

<div align="center">

**Built with ❤️ using NixOS • 简单即是美**

[![Built with Nix](https://img.shields.io/static/v1?label=Built%20with&message=Nix&color=5277C6&style=for-the-badge&logo=nixos)](https://nixos.org)

</div>