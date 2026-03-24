# 🚀 NixOS Flake 多硬件配置系统

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-25.11-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Linux](https://img.shields.io/badge/Linux-Latest-yellow?style=for-the-badge&logo=linux)
![Flakes](https://img.shields.io/badge/Flakes-Enabled-purple?style=for-the-badge&logo=nix)

**模块化、可切换的多硬件 NixOS 系统配置**

[📋 配置概览](#-配置概览) • [🖥️ 桌面环境](#-桌面环境) • [📦 软件包](#-软件包) • [⚙️ 系统优化](#-系统优化) • [🔧 使用指南](#-使用指南) • [📁 目录结构](#-目录结构)

</div>

---

## 📋 配置概览

### 核心信息

| 项目 | 配置 |
|------|------|
| **系统版本** | NixOS 25.11 |
| **配置管理** | Flakes + Home Manager |
| **桌面环境** | KDE Plasma 6 (Wayland 优先) |
| **显示管理器** | SDDM (Breeze 主题) |
| **内核** | Linux Latest (最新稳定版) |
| **文件系统** | BTRFS (带自动 scrub) |
| **主机名** | nixos (可动态切换) |
| **用户** | zhangchongjie |
| **默认 Shell** | Fish |
| **时区** | Asia/Shanghai |
| **语言** | zh_CN.UTF-8 |

### 支持的硬件配置

本配置系统支持多硬件动态切换，通过 Flake 输出不同配置：

| 配置名称 | CPU | GPU | 主机名 |
|---------|-----|-----|--------|
| `nixos` (默认) | Ryzen 2600 | RX 5500 | nixos-2600-rx5500 |
| `nixos-1600x-r9370` | Ryzen 1600X | R9 370 | nixos-1600x-r9370 |
| `nixos-2600-rx6600xt` | Ryzen 2600 | RX 6600 XT | nixos-2600-rx6600xt |
| `nixos-3600-rx6600xt` | Ryzen 3600 | RX 6600 XT | nixos-3600-rx6600xt |

---

## 🖥️ 桌面环境

### 核心组件

- **显示协议**: Wayland (原生) + X11 兼容
- **桌面环境**: KDE Plasma 6
- **显示管理器**: SDDM
  - 主题：Breeze Twilight
  - 默认会话：Plasma (Wayland)
  - 背景：Mountain 壁纸 (5120x2880)
- **输入法**: Fcitx5
  - Rime 引擎
  - 中文拼音支持
  - Qt6 配置工具

### 多媒体支持

- **音频服务**: PipeWire
  - PulseAudio 兼容层
  - ALSA 支持 (32 位)
  - JACK 支持
- **蓝牙**: 已启用
- **打印服务**: 禁用

### 指针与主题

- **光标主题**: Papirus (24px)
- **图标主题**: Papirus
- **窗口装饰**: Breeze Twilight
- **Qt 平台主题**: KDE Breeze

---

## 📦 软件包

### 🔧 开发工具

#### 系统级
- **VSCode** - 主代码编辑器
- **Git** - 版本控制 (配置优化)
- **Vim** - 文本编辑器
- **Zellij** - Terminal 多路复用器
- **Alacritty** - GPU 加速终端模拟器

#### 用户级 (Home Manager)
- **JetBrains Mono** - 编程字体
- **Fira Code** - 连字编程字体

### 🌐 网络应用

- **Firefox** - 浏览器 (Wayland 原生)
- **Clash Verge Rev** - 代理客户端
- **FlClash** - 备选代理客户端
- **KDE Connect** - 设备互联

### 🎮 游戏相关

- **Lutris (Free)** - 游戏平台
- **ProtonUp-Qt** - Proton 管理工具

### 🛠️ 系统工具

- **Fastfetch** - 系统信息显示
- **Timeshift** - 系统备份
- **BleachBit** - 系统清理
- **Home Manager** - 用户配置管理
- **Flatpak** - 通用包管理
- **Radeontop** - AMD GPU 监控
- **Vkmark** - Vulkan 基准测试
- **Vulkan Tools** - Vulkan 工具集

### 🎨 图形与媒体

- **FFmpeg (Full)** - 完整音视频处理
- **Mesa** - 开源图形驱动
- **ROCM CLR** - OpenCL 运行库
- **VA-API/VDPAU** - 视频编解码加速

### 📱 Flatpak 支持

- Flatpak 运行时已启用
- 自动字体映射配置
- 系统图标/字体只读绑定

---

## ⚙️ 系统优化

### 🚀 性能优化

#### 内核参数

**显示器分辨率策略**：
- ✅ **自动检测 EDID**：移除硬编码的 `video=` 参数
- ✅ **KScreen 自动管理**：KDE Plasma Wayland 自动检测显示器并应用最大分辨率
- ✅ **热插拔支持**：更换显示器（如 4K）时自动适配，无需修改配置
- ✅ **多显示器拓扑**：自动识别并配置多显示器布局

```

```

其他全局参数：
- TCP 拥塞控制：BBR
- TCP Fastopen：启用 (级别 3)
- 网络队列调度：FQ
- 内存交换策略：Swappiness = 1 (最小化 swap 使用)
- 页面表隔离：禁用 (AMD Ryzen 优化)

#### 内存管理

- **Swappiness**: 1 (最小化 swap 使用，可被硬件模块覆盖)
- **VFS 缓存压力**: 100 (可被硬件模块覆盖)
- **页面预读**: 禁用 (SSD 优化)
- **脏页比例**: 20% (Ryzen 优化)

#### 文件系统优化

- **BTRFS**: 
  - 每周自动碎片整理
  - 定期 scrub 检查
  - 根文件系统优化
- **SSD TRIM**: 定期执行
- **Inotify 监视数**: 524288

### 💾 zRAM Swap

- **启用**: 是
- **大小**: 50% 物理内存
- **压缩算法**: ZSTD
- **优先级**: 100

### 🔋 电源管理

#### CPU 频率调节

- **默认策略**: Performance (高性能)
- **AMD P-State**: 主动模式 (Ryzen 2600+)
- **Powertop**: 启用 (自动调优)

#### USB 电源管理

- **自动挂起**: 禁用 (提高稳定性)
- **三层防护**: 内核参数 + systemd + udev

### 🎯 AMD GPU 优化 (RX 5500)

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
amdgpu.sched_hw_submission=256 # 调度优化
```

#### 显示分辨率管理

**自动检测策略**：
- ✅ **EDID 读取**：内核 DRM 子系统自动读取显示器 EDID 信息
- ✅ **KScreen 服务**：KDE Plasma 的 KScreen 守护进程动态管理分辨率
- ✅ **Wayland 原生支持**：无需 X11 配置，合成器自动处理缩放
- ✅ **热插拔检测**：更换显示器时自动重新配置（如 4K 显示器即插即用）

**支持的分辨率范围**：
- 最低：640x480@60Hz
- 最高：7680x4320@60Hz (取决于硬件和接口带宽)
- 刷新率：根据显示器 EDID 自动选择最佳值

#### 图形加速

- **Vulkan**: 启用 (含 32 位)
- **OpenCL**: ROCMR CLR
- **VA-API/VDPAU**: 视频编解码
- **Mesa**: 最新版的

### 🔒 安全设置

- **Sudo**: Wheel 组需密码
- **防火墙**: 启用 (沙箱模式)
- **Core Dump**: 禁用
- **TUN 模块**: 加载 (FlClash)
- **PTI**: 按硬件配置动态启用/禁用

---

## 🌐 网络配置

### 防火墙

- **状态**: 启用
- **允许 Ping**: 是
- **反向路径检查**: 启用
- **开放端口**:
  - TCP: 7897 (Clash Dashboard)
  - UDP/TCP: 1714-1764 (KDE Connect)

### 代理服务

- **HTTP Proxy**: http://127.0.0.1:7897
- **HTTPS Proxy**: http://127.0.0.1:7897
- **No Proxy**: 127.0.0.1, localhost, *.local

### 服务发现

- **Avahi/mDNS**: 启用 (IPv4)
- **systemd-resolved**: 启用
- **DNS 服务器**: 119.29.29.29, 223.5.5.5

---

## 👤 用户配置

### 主用户：zhangchongjie

- **用户组**: networkmanager, wheel, flatpak, video, render, input
- **默认 Shell**: Fish
- **Sudo 权限**: 需要密码

### Fish Shell 配置

#### 实用别名

```
ll = "ls -la"
la = "ls -A"
rebuild = "sudo -E nixos-rebuild switch"
rebuild-test = "sudo -E nixos-rebuild test"
hm-switch = "home-manager switch"
c = "clear"
s = "sudo"
update = "sudo nixos-rebuild switch"
gc = "sudo nix-collect-garbage -d"
optimise = "sudo nix-store --optimise"
```

#### 重建命令

- **rebuild-flake**: 使用国内镜像源重建
- **rebuild-offline**: 离线重建 (无网络)

#### 目录导航

- **cdup**: cd ..
- **cd2up**: cd ../..
- **cd3up**: cd ../../..

### Git 配置

- **用户名**: zhangchongjie
- **邮箱**: 778280151@qq.com
- **默认分支**: main
- **编辑器**: Vim
- **推送策略**: Simple (自动设置 upstream)
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

```
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos
```

#### 2. 选择硬件配置

查看可用配置：

```
nix flake show
```

#### 3. 构建并切换

**默认配置** (当前设备：Ryzen 2600 + RX 5500):

```
sudo nixos-rebuild switch --flake .#nixos
```

**切换到其他硬件配置**:

```
# Ryzen 1600X + R9 370
sudo nixos-rebuild switch --flake .#nixos-1600x-r9370

# Ryzen 2600 + RX 6600 XT
sudo nixos-rebuild switch --flake .#nixos-2600-rx6600xt

# Ryzen 3600 + RX 6600 XT
sudo nixos-rebuild switch --flake .#nixos-3600-rx6600xt
```

#### 4. 初始化 Home Manager

```
home-manager switch --flake .#nixos.users.zhangchongjie
```

### 日常维护

#### 系统重建 (推荐工作流)

```
cd /etc/nixos

# 快速重建 (使用本地 lock 文件，无需网络)
sudo nixos-rebuild switch --flake .#nixos

# 或使用 Fish alias
rebuild
```

#### 更新依赖 (需网络)

```
# 更新 flake inputs (每月/每季度执行)
nix flake update

# 更新 channel (可选)
sudo nix-channel --update
```

#### 垃圾回收

```
# 清理旧世代
sudo nix-collect-garbage -d

# 或使用 alias
gc

# 优化存储
sudo nix-store --optimise
```

#### 查看系统信息

```
fastfetch
# 或
neofetch
```

### 故障排查

#### 无法启动

```
# 进入恢复模式
nixos-rebuild boot --flake .#nixos

# 重启 NetworkManager
sudo systemctl restart NetworkManager

# 清理 7 天前的世代
sudo nix-collect-garbage --delete-older-than 7d
```

#### 二进制缓存问题

```
# 临时禁用所有缓存 (纯净模式测试)
sudo nixos-rebuild switch --flake .#nixos --option substituters ""

# 使用命令行指定镜像源
sudo nixos-rebuild switch --flake .#nixos \
  --option substituters "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
```

#### 验证配置

```
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

## 🔧 常见问题与故障排除

### Flatpak VSCode 找不到系统工具 (nix-instantiate)

**问题**: 在 VSCode 中遇到错误提示 `nix-instantiate not found in $PATH. Linting is disabled.`

**原因**: Flatpak 版 VSCode 运行在沙箱中，无法访问 NixOS 的系统路径 `/run/current-system/sw/bin`。

**解决方案**:

1. **自动修复（推荐）**:
   ```bash
   cd /etc/nixos/scripts
   ./fix-vscode-nix-access.sh
   ```

2. **手动配置**:
   - 创建配置文件 `~/.var/app/com.visualstudio.code/config/environment-override.conf`
   - 添加内容:
     ```conf
     PATH=/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin
     ```
   - 完全重启 VSCode

3. **验证**: 在 VSCode 终端运行 `which nix-instantiate`

详细说明请参考 [FLATPAK_VSCODE_NIX_FIX.md](./FLATPAK_VSCODE_NIX_FIX.md)

### Flatpak VSCode 终端启动目录不存在

**问题**: 
```
终端进程启动失败：启动目录 (cwd)"/run/flatpak/doc/... (deleted)"不存在。
```

**原因**: Flatpak 沙箱文档门户（portal）路径与实际路径不一致，导致 VSCode使用错误的启动目录。

**解决方案**:

1. **自动修复（推荐）**:
   ```bash
   cd /etc/nixos/scripts
   ./fix-vscode-cwd.sh
   ```

2. **手动配置**:
   - 打开 VSCode 设置 (`Ctrl+,`)
   - 搜索 `terminal.integrated.cwd`
   - 设置为你的主目录绝对路径（如 `/home/zhangchongjie`）
   
   或编辑 `~/.config/Code/User/settings.json`:
   ```json
   {
     "terminal.integrated.cwd": "/home/zhangchongjie"
   }
   ```

3. **重启 VSCode**

**验证**: 在 VSCode 终端运行 `pwd`，应该输出你的主目录路径而不是 `/run/flatpak/doc/...`

详细说明请参考 [SOLUTION_SUMMARY.md](./SOLUTION_SUMMARY.md)

### 其他常见问题

#### 网络代理问题
如果遇到网络连接问题，检查 FlClash 是否正常运行：
```bash
systemctl --user status flclash
```

#### 输入法不工作
确保 Fcitx5 已正确启动：
```bash
systemctl --user status fcitx5
```

#### 系统重建失败
使用测试模式先验证配置：
```bash
sudo nixos-rebuild test --flake .
```

---

<div align="center">

**Made with ❤️ using NixOS Flakes**

如果这份配置对你有帮助，欢迎 Star ⭐

[![Built with Nix](https://img.shields.io/static/v1?label=Built%20with&message=Nix&color=5277C6&style=for-the-badge&logo=nixos)](https://nixos.org)

</div>
