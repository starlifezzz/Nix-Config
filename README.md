# 🚀 NixOS Flake 多硬件配置系统

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-25.11-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-purple?style=for-the-badge&logo=nix)

**模块化、可切换的多硬件 NixOS 系统配置**

[📋 核心配置](#-核心配置) • [🖥️ 桌面环境](#️-桌面环境) • [📦 软件包](#-软件包) • [⚙️ 系统优化](#️-系统优化) • [🔧 使用指南](#-使用指南) • [📁 目录结构](#-目录结构)

</div>

---

## 📋 核心配置

### 系统信息

| 项目 | 配置 |
|------|------|
| **系统版本** | NixOS 25.11 (Unstable) |
| **配置管理** | Flakes + Home Manager |
| **桌面环境** | KDE Plasma 6 (Wayland 原生) |
| **显示管理器** | SDDM (Wayland 支持) |
| **内核** | Linux Latest (最新稳定版) |
| **文件系统** | BTRFS (自动 scrub) |
| **默认 Shell** | Fish |
| **时区** | Asia/Shanghai |
| **语言** | zh_CN.UTF-8 |

### 支持的硬件配置

通过 Flake 输出多硬件配置，支持快速切换：

| 配置名称 | CPU | GPU | 主机名 |
|---------|-----|-----|--------|
| `nixos` (默认) | Ryzen 2600 | RX 5500 | nixos-2600-rx5500 |
| `nixos-1600x-r9370` | Ryzen 1600X | R9 370 | nixos-1600x-r9370 |
| `nixos-2600-rx6600xt` | Ryzen 2600 | RX 6600 XT | nixos-2600-rx6600xt |
| `nixos-3600-rx6600xt` | Ryzen 3600 | RX 6600 XT | nixos-3600-rx6600xt |

---

## 🖥️ 桌面环境

### 核心组件

- **显示协议**: Wayland 原生 (X11 兼容层)
- **桌面环境**: KDE Plasma 6
- **显示管理器**: SDDM
  - Wayland 会话已启用
  - 默认会话：Plasma
- **输入法**: Fcitx5
  - Rime 引擎
  - 中文拼音支持
  - Qt6 集成

### 多媒体

- **音频**: PipeWire
  - PulseAudio 兼容层
  - ALSA 支持 (32 位)
  - JACK 支持
- **打印服务**: 禁用

---

## 📦 软件包

### 开发工具

#### 系统级
- **VSCode** - 主代码编辑器
- **Git** - 版本控制
- **Vim** - 文本编辑器
- **Alacritty** - GPU 加速终端
- **Zellij** - Terminal 多路复用器

#### 用户级 (Home Manager)
- **JetBrains Mono** - 编程字体
- **Fira Code** - 连字编程字体

### 网络应用

- **Firefox** - 浏览器 (Wayland 原生)
- **Clash Verge Rev** - 代理客户端
- **KDE Connect** - 设备互联

### 游戏相关

- **Lutris** - 游戏平台
- **桌面快捷方式**: 已通过 `xdg.dataFile` 配置

### 系统工具

- **Fastfetch** - 系统信息显示
- **Timeshift** - 系统备份
- **BleachBit** - 系统清理
- **Home Manager** - 用户配置管理
- **Flatpak** - 通用包管理
- **FFmpeg (Full)** - 音视频处理

---

## ⚙️ 系统优化

### 性能优化

#### 内核参数

**显示器分辨率策略**：
- ✅ **自动检测 EDID**：移除硬编码的 `video=` 参数
- ✅ **KScreen 自动管理**：KDE Plasma Wayland 自动检测显示器并应用最佳分辨率
- ✅ **热插拔支持**：更换显示器（如 4K）时自动适配，无需修改配置

**USB 稳定性优化**：
```
"usbcore.autosuspend=-1"       # 禁用 USB 自动挂起
"usbcore.usbfs_memory_mb=1024" # USBFS 内存优化
```

**其他优化**：
- TCP 拥塞控制：BBR
- 内存交换策略：Swappiness = 1 (最小化 swap)
- 页面表隔离：针对 AMD 优化

#### 内存管理

- **Swappiness**: 1 (最小化 swap 使用)
- **VFS 缓存压力**: 100
- **Inotify 监视数**: 524288

#### 文件系统

- **BTRFS**: 
  - 每周自动碎片整理
  - 定期 scrub 检查
- **SSD TRIM**: 定期执行

### zRAM Swap

- **启用**: 是
- **大小**: 50% 物理内存
- **压缩算法**: ZSTD
- **优先级**: 100

### 电源管理

#### CPU 频率调节

- **默认策略**: Performance (高性能)
- **AMD P-State**: 主动模式 (Ryzen 2600+)

#### USB 电源管理

- **自动挂起**: 禁用 (提高稳定性)

### AMD GPU 优化 (RX 5500)

#### 驱动与内核模块

- **驱动**: AMDGPU (内核内置)
- **Initrd 加载**: 是
- **运行库**: 完整固件

#### 内核参数

```
amdgpu.runpm=0                 # 禁用运行时 PM
pcie_aspm=performance          # PCIe ASPM 性能模式
amdgpu.ppfeaturemask=0xffffffff # 启用所有特性
amdgpu.dc=1                    # Display Core
```

#### 图形加速

- **Vulkan**: 启用 (含 32 位)
- **OpenCL**: ROCm CLR
- **VA-API/VDPAU**: 视频编解码

### 安全设置

- **Sudo**: Wheel 组需密码
- **防火墙**: 启用
- **TUN 模块**: 加载 (FlClash)

---

## 🌐 网络配置

### 防火墙

- **状态**: 启用
- **允许 Ping**: 是
- **开放端口**:
  - TCP: 7897 (Clash Dashboard)
  - UDP/TCP: 1714-1764 (KDE Connect)

### 代理服务

- **HTTP Proxy**: http://127.0.0.1:7897
- **HTTPS Proxy**: http://127.0.0.1:7897
- **No Proxy**: localhost, 127.0.0.1, ::1, .localdomain.com

### DNS

- **DNS 服务器**: 119.29.29.29, 223.5.5.5
- **Avahi/mDNS**: 启用 (IPv4)

---

## 👤 用户配置

### 主用户：zhangchongjie

- **用户组**: networkmanager, wheel, flatpak, video, render, input
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
```

#### 重建命令

- **rebuild-flake**: 使用国内镜像源重建
- **rebuild-offline**: 离线重建 (无网络)

### Git 配置

- **用户名**: zhangchongjie
- **邮箱**: 778280151@qq.com
- **默认分支**: main
- **编辑器**: Vim
- **推送策略**: Simple
- **拉取策略**: Rebase
- **自动修剪**: 启用

---

## 🔧 Nix 配置

### 二进制缓存 (镜像源)

优先级从高到低：

1. https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store
2. https://mirrors.ustc.edu.cn/nix-channels/store
3. https://mirrors.cernet.edu.cn/nix-channels/store
4. https://cache.nixos.org

**公钥**: cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=

### 实验特性

- ✅ Nix Command
- ✅ Flakes

### 垃圾回收

- **自动 GC**: 每天执行
- **保留策略**: 删除 >3 天的 derivations
- **存储优化**: 自动启用

### 并行构建

- **最大任务数**: Auto (CPU 核心数)
- **构建核心数**: 0 (无限制)
- **沙箱**: 启用

---

## 📁 目录结构

```
/etc/nixos/
├── configuration.nix              # 系统主配置
├── hardware-configuration-2600.nix # 当前硬件配置 (BTRFS)
├── flake.nix                      # Flakes 多硬件配置入口 ⭐
├── flake.lock                     # 版本锁定文件
├── .gitignore                     # Git 忽略规则
├── README.md                      # 项目文档
│
├── home/                          # Home Manager 用户配置
│   ├── default.nix               # Home Manager 入口
│   ├── home.nix                  # Fish + Git 配置
│   ├── kde.nix                   # KDE Plasma 详细配置
│   ├── Alacritty.nix             # Alacritty 终端配置
│   └── zellij.nix                # Zellij 多路复用器配置
│
├── modules/hardware/              # 自定义硬件模块 ⭐
│   ├── detection.nix             # 基础选项定义
│   ├── cpu/                      # CPU 特定配置
│   │   ├── ryzen-1600x.nix
│   │   ├── ryzen-2600.nix        # 当前使用
│   │   └── ryzen-3600.nix
│   └── gpu/                      # GPU 特定配置
│       ├── r9-370.nix
│       ├── rx-5500.nix           # 当前使用
│       └── rx-6600xt.nix
│
└── scripts/                       # 实用脚本 (预留)
```

---

## 🔧 使用指南

### 前置要求

1. **BIOS 设置**:
   - 启用 EFI 启动
   - 禁用 Secure Boot
   - 启用 AHCI/SATA 模式

2. **网络准备**:
   - 首次构建需访问 GitHub (下载 flake inputs)
   - 建议配置代理或使用镜像源

### 系统部署

#### 1. 克隆配置

```bash
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos
```

#### 2. 选择硬件配置

查看可用配置：

```bash
nix flake show
```

#### 3. 构建并切换

**默认配置** (当前设备：Ryzen 2600 + RX 5500):

```bash
sudo nixos-rebuild switch --flake .#nixos
```

**切换到其他硬件配置**:

```bash
# Ryzen 1600X + R9 370
sudo nixos-rebuild switch --flake .#nixos-1600x-r9370

# Ryzen 2600 + RX 6600 XT
sudo nixos-rebuild switch --flake .#nixos-2600-rx6600xt

# Ryzen 3600 + RX 6600 XT
sudo nixos-rebuild switch --flake .#nixos-3600-rx6600xt
```

#### 4. 初始化 Home Manager

```bash
home-manager switch --flake .#nixos.users.zhangchongjie
```

### 日常维护

#### 系统重建 (推荐工作流)

```bash
cd /etc/nixos

# 快速重建 (使用本地 lock 文件，无需网络)
sudo nixos-rebuild switch --flake .#nixos

# 或使用 Fish alias
rebuild
```

#### 更新依赖 (需网络)

```bash
# 更新 flake inputs (每月/每季度执行)
nix flake update

# 更新 channel (可选)
sudo nix-channel --update
```

#### 垃圾回收

```bash
# 清理旧世代
sudo nix-collect-garbage -d

# 或使用 alias
gc

# 优化存储
sudo nix-store --optimise
```

#### 查看系统信息

```bash
fastfetch
```

### 故障排查

#### 无法启动

```bash
# 进入恢复模式
nixos-rebuild boot --flake .#nixos

# 重启 NetworkManager
sudo systemctl restart NetworkManager

# 清理 7 天前的世代
sudo nix-collect-garbage --delete-older-than 7d
```

#### 二进制缓存问题

```bash
# 临时禁用所有缓存 (纯净模式测试)
sudo nixos-rebuild switch --flake .#nixos --option substituters ""

# 使用命令行指定镜像源
sudo nixos-rebuild switch --flake .#nixos \
  --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
```

#### 验证配置

```bash
# 检查语法
nix flake check

# 仅构建不切换
sudo nixos-rebuild build --flake .#nixos

# 查看生成的配置
nix eval '.#nixos.config'
```

---

## 🎯 设计原则

### 模块化架构

1. **硬件解耦**: CPU/GPU 配置完全分离，可自由组合
2. **动态导入**: 使用 `lib.optional + builtins.pathExists` 安全包含模块
3. **参数传递**: 通过 `specialArgs` 传递硬件参数到所有层级

### 配置规范

1. **单一干预**: 仅针对具体问题优化，避免多重干预
2. **默认保守**: 优先使用 NixOS 默认值，确保稳定性
3. **作用域清晰**: 系统级 vs 用户级职责分明

### 可维护性

1. **版本锁定**: flake.lock 确保可重复构建
2. **条件导入**: 硬件模块按需加载
3. **命名约定**: 标准化配置命名 (nixos-{cpu}-{gpu})

---

## 📝 注意事项

### 首次启动

1. 确保 BIOS 中启用了 EFI 启动
2. 准备好网络连接 (有线优先)
3. 首次构建时间较长 (约 30-60 分钟)

### 网络配置

- **代理设置**: 根据需要修改 `environment.variables` 中的代理地址
- **镜像源**: 已配置国内镜像，若失效请参考 NixOS 官方文档更新
- **离线使用**: 日常重建无需网络 (使用本地 lock 文件)

### 用户安全

- 首次启动后记得设置用户密码：
  ```bash
  sudo passwd zhangchongjie
  ```
- 若需免密码 sudo，修改 `users.users.<name>.extraGroups` 添加 `nopasswd`

### Flatpak 使用

首次使用后添加远程仓库：

```bash
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub
```

### 硬件切换

- 切换硬件配置后建议重启系统
- 不同硬件的 firmware 可能不同，请确保内核固件包完整
- 建议在 `/etc/nixos` 目录下执行重建命令

---

## 📚 参考资料

- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [Nix 配置选项](https://search.nixos.org/options)
- [Nixpkgs 软件包搜索](https://search.nixos.org/packages)
- [Home Manager](https://github.com/nix-community/home-manager)
- [NixOS Hardware](https://github.com/NixOS/nixos-hardware)
- [Flakes 文档](https://nixos.wiki/wiki/Flakes)

---

## 🛠️ 技术栈

- **基础系统**: NixOS 25.11
- **配置管理**: Nix Flakes
- **用户配置**: Home Manager
- **桌面环境**: KDE Plasma 6
- **显示协议**: Wayland
- **硬件支持**: AMD Ryzen + AMD Radeon

---

<div align="center">

**Made with ❤️ using NixOS Flakes**

[![Built with Nix](https://img.shields.io/static/v1?label=Built%20with&message=Nix&color=5277C6&style=for-the-badge&logo=nixos)](https://nixos.org)

</div>

```
# NixOS 配置说明

本目录包含 NixOS 系统的完整配置。

## 📁 文件结构

```
/etc/nixos/
├── configuration.nix          # 主配置文件
├── flake.nix                  # Flake 配置（可选）
├── hardware-configuration.nix # 硬件配置（自动生成）
├── scripts/                   # 自定义脚本
│   ├── start-clash-tun.sh    # Clash TUN 启动脚本
│   └── check-clash-tun.sh    # Clash TUN 检查脚本
├── CLASH_TUN_GUIDE.md         # Clash TUN 详细指南
└── README.md                  # 本文件
```

## 🚀 快速开始

### 系统重建

```bash
sudo nixos-rebuild switch
```

### 应用更新后重建

```bash
sudo nixos-rebuild switch --upgrade
```

## 🔧 常用命令

### Clash TUN 模式

```bash
# 启动 TUN 模式
sudo clash-tun

# 检查状态
sudo check-clash-tun.sh

# 停止
sudo pkill -f verge-mihomo
```

### 系统维护

```bash
# 查看当前配置
nixos-rebuild build

# 回滚到上一代
sudo nixos-rebuild switch --rollback

# 清理旧世代
sudo nix-collect-garbage -d
```

## 📚 文档链接

- [Clash TUN 配置指南](./CLASH_TUN_GUIDE.md) - 详细的 TUN 模式配置和故障排查
- [NixOS 官方文档](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://wiki.nixos.org/)

## ⚙️ 系统信息

- **主机名**: nixos
- **用户**: zhangchongjie
- **桌面环境**: COSMIC (Wayland)
- **网络**: iptables 防火墙

## 📝 注意事项

1. **TUN 设备易失性** - 每次重启后需要重新运行 `sudo clash-tun`
2. **用户组修改** - 添加到 `netadmin` 组后需要重新登录
3. **防火墙服务** - 修改 firewall 配置后需重启服务或重建系统

---

**最后更新**: 2026-03-25
