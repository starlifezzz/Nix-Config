# 🚀 NixOS 系统配置 - 极简手动硬件选择

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-26.05-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Home Manager](https://img.shields.io/badge/Home_Manager-Integrated-purple?style=for-the-badge&logo=nix)

**简单直接的模块化 NixOS 配置 • 手动指定硬件 • 清晰可预测**

[📋 快速开始](#-快速开始) • [🔧 切换硬件](#-切换硬件配置) • [📦 软件包](#-软件包) • [⚙️ 系统优化](#️-系统优化) • [📁 目录结构](#-目录结构)

</div>

---

## 🎯 架构特点

### ⚡ 设计理念

**放弃 Flakes 的"伪动态"，回归简单直接！**

- ✅ **CPU/GPU 配置直接硬编码在 [`configuration.nix`](configuration.nix)**
- ✅ **`flake.nix` 只保留最简框架（用于 Home Manager）**
- ✅ **支持 `sudo nixos-rebuild switch --flake .#nixos` 构建**
- ✅ **配置清晰明了，一眼看出用的什么硬件**

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

### 当前硬件配置

**CPU**: AMD Ryzen 5 1600X  
**GPU**: AMD Radeon R9 370

### 首次部署

```
# 1. 克隆配置到 /etc/nixos
sudo su
cd /etc
git clone <your-repo-url> nixos
cd nixos

# 2. 构建并切换
sudo nixos-rebuild switch --flake .#nixos

# 3. 设置用户密码
sudo passwd zhangchongjie
```

---

## 🔧 切换硬件配置

### 步骤超简单

#### 1️⃣ 编辑 [`configuration.nix`](configuration.nix)

找到第 6-20 行的 `imports` 部分：

```
imports =
  [
    # ... 其他配置保持不变 ...
    
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
- `./modules/hardware/cpu/ryzen-1600x.nix` ← 当前
- `./modules/hardware/cpu/ryzen-2600.nix`
- `./modules/hardware/cpu/ryzen-3600.nix`

**GPU 选项**（`modules/hardware/gpu/`）：
- `./modules/hardware/gpu/r9-370.nix` ← 当前
- `./modules/hardware/gpu/rx-5500.nix`
- `./modules/hardware/gpu/rx-6600xt.nix`

#### 3️⃣ 执行构建

```
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

或使用 Fish Shell 别名：
```fish
rebuild-flake  # 已配置国内镜像源
```

#### 4️⃣ 重启系统（建议）

```
reboot
```

### ⚡ 架构优势

**✅ 直接了当**: 配置文件路径就是硬件型号，一目了然  
**✅ 无需判断**: 移除了所有 `lib.mkIf` 条件判断  
**✅ 即改即用**: 修改 imports 后立即生效  
**✅ 清晰透明**: 没有隐式逻辑或动态检测

### 💡 示例：切换到 Ryzen 2600 + RX 5500

**Step 1**: 编辑 `configuration.nix`
```diff
  imports =
    [
      # ... 其他配置 ...
-     ./modules/hardware/cpu/ryzen-1600x.nix
+     ./modules/hardware/cpu/ryzen-2600.nix
-     ./modules/hardware/gpu/r9-370.nix
+     ./modules/hardware/gpu/rx-5500.nix
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

### 网络应用

- **Firefox** - 浏览器 (Wayland 原生)
- **Clash Verge Rev** - 代理客户端 (TUN 模式)
- **FlClash** - 备用代理客户端
- **KDE Connect** - 设备互联

### 游戏相关

- **Lutris** - 游戏平台
- 桌面快捷方式已配置

### 系统工具

- **Fastfetch** - 系统信息显示
- **Timeshift** - 系统备份
- **BleachBit** - 系统清理
- **Flatpak** - 通用包管理
- **FFmpeg (Full)** - 音视频处理
- **Node.js** - JavaScript 运行时 (完整版，支持 MCP Server)

---

## ⚙️ 系统优化

### 性能优化

#### 内核参数

**显示器分辨率策略**：
- ✅ **自动检测 EDID**：移除硬编码的 `video=` 参数
- ✅ **KScreen 自动管理**：KDE Plasma Wayland 自动检测并应用最佳分辨率
- ✅ **热插拔支持**：更换显示器自动适配

**USB 稳定性优化**：
```
usbcore.autosuspend=-1       # 禁用 USB 自动挂起
usbcore.usbfs_memory_mb=1024 # USBFS 内存优化
```

**其他优化**：
- TCP 拥塞控制：BBR
- 内存交换策略：Swappiness = 1 (最小化 swap)
- AMD P-State：主动模式 (Ryzen 2600+)

#### 内存管理

- **Swappiness**: 1
- **VFS 缓存压力**: 100
- **Inotify 监视数**: 524288

#### 文件系统

- **BTRFS**: 
  - 每周自动碎片整理
  - 定期 scrub 检查
- **SSD TRIM**: 定期执行

### zRAM Swap

- **启用**: 是（仅 Ryzen 1600X，8GB 内存专属）
- **大小**: 90% 物理内存
- **压缩算法**: ZSTD
- **优先级**: 100

### AMD GPU 优化 (R9 370)

#### 驱动与内核模块

- **驱动**: AMDGPU (内核内置)
- **Initrd 加载**: 是
- **运行库**: 完整固件

#### 内核参数

```
amdgpu.runpm=0                 # 禁用运行时 PM
amdgpu.dpm=1                   # 动态电源管理
amdgpu.dc=0                    # 禁用 Display Core (R9 370 不支持)
amdgpu.si_support=1            # Southern Islands 支持
radeon.si_support=0            # 禁用旧驱动
pcie_aspm=off                  # 禁用 ASPM 提高稳定性
```

#### 图形加速

- **Vulkan**: 禁用 (R9 370 不支持)
- **OpenCL**: Mesa OpenCL
- **VA-API/VDPAU**: 视频编解码

### 安全设置

- **Sudo**: Wheel 组需密码
- **防火墙**: 启用
- **TUN 模块**: 加载 (Clash Verge Rev)
- **网络管理权限**: netadmin 组

---

## 👤 用户配置

### 主用户：zhangchongjie

- **用户组**: networkmanager, wheel, flatpak, video, render, input, netadmin
- **默认 Shell**: Fish
- **Sudo 权限**: 需要密码

### Fish Shell 配置

#### 实用别名

``fish
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
  - TCP: 7897 (Clash Dashboard), 7890-7891 (代理端口), 9090 (External Controller)
  - UDP/TCP: 1714-1764 (KDE Connect)

### 代理服务

- **Clash Verge Rev**: 主代理客户端
  - TUN 模式：启动脚本自动配置
  - HTTP 代理：http://127.0.0.1:7897
  - SOCKS5 代理：socks5://127.0.0.1:7891
- **FlClash**: 备用代理客户端

### DNS

- **DNS 服务器**: 119.29.29.29 (腾讯 DNSPod), 223.5.5.5 (阿里 DNS)
- **DNSSEC**: 禁用
- **Avahi/mDNS**: 启用 (IPv4)

---

## 📁 目录结构

```
/etc/nixos/
├── configuration.nix              # 系统主配置 ⭐ (直接导入 CPU/GPU 模块)
├── hardware-configuration.nix     # 硬件配置 (BTRFS, 自动生成)
├── flake.nix                      # Flakes 入口 (简化版，仅用于 Home Manager)
├── flake.lock                     # 版本锁定文件
├── .gitignore                     # Git 忽略规则
│
├── home/                          # Home Manager 用户配置
│   ├── default.nix               # Home Manager 入口
│   ├── home.nix                  # Fish + Git 配置
│   ├── kde.nix                   # KDE Plasma 详细配置
│   ├── alacritty.nix             # Alacritty 终端配置
│   ├── vim.nix                   # Vim 配置
│   ├── direnv.nix                # direnv 配置
│   ├── git.nix                   # Git 配置
│   └── zellij.nix                # Zellij 多路复用器配置
│
├── modules/hardware/              # 自定义硬件模块
│   ├── cpu/                      # CPU 特定配置
│   │   ├── ryzen-1600x.nix
│   │   ├── ryzen-2600.nix        # ← 当前使用
│   │   └── ryzen-3600.nix
│   └── gpu/                      # GPU 特定配置
│       ├── r9-370.nix
│       ├── rx-5500.nix           # ← 当前使用
│       ├── rx-5500xt.nix
│       ├── rx-5700.nix
│       ├── rx-5700-xt.nix
│       └── rx-6600xt.nix
│
├── scripts/                       # 实用脚本
│   ├── start-clash-tun.sh        # Clash TUN 模式启动
│   └── check-clash-tun.sh        # TUN 状态检查
│
├── QUICK_REFERENCE.md             # 快速参考手册
├── ARCHITECTURE_CHANGE.md         # 架构改进说明
└── README.md                      # 本文档
```

---

## 💡 架构演进

### 最新版本 (2026-03-29)

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

---

## 🖼️ SDDM 登录屏幕壁纸配置

### ✅ 已配置功能

SDDM 显示管理器现已支持自定义壁纸，配置位于 [`configuration.nix`](configuration.nix) 的 `services.displayManager.sddm` 部分。

### 🎨 更换壁纸方法

#### 方式 1：使用自定义壁纸（推荐）

1. **准备壁纸文件**
   
   将你的壁纸图片（JPG/PNG 格式）放置到：
   ```
   /etc/nixos/wallpapers/sddm-background.jpg
   ```

2. **支持的格式**
   - JPG/JPEG
   - PNG
   - 推荐分辨率：1920x1080 或更高

3. **应用新壁纸**
   ```bash
   cd /etc/nixos
   sudo nixos-rebuild switch --flake .#nixos
   ```

4. **重启 SDDM 或系统**
   ```bash
   # 方式 1：重启 display-manager 服务
   sudo systemctl restart display-manager.service
   
   # 方式 2：直接重启系统
   reboot
   ```

#### 方式 2：使用 KDE 默认壁纸

如果 `/etc/nixos/wallpapers/sddm-background.jpg` 不存在，系统会自动使用 KDE Plasma 的默认壁纸。

### 🎯 配置选项

在 [`configuration.nix`](configuration.nix) 中可以调整以下参数：

```nix
services.displayManager.sddm = {
  enable = true;
  wayland.enable = true;
  settings = {
    General = {
      Background = "/etc/nixos/wallpapers/sddm-background.jpg";  # 壁纸路径
    };
    Theme = {
      Current = "chili";  # 主题：chili, elarun, maya, breath
      # Color = "#313648";  # 纯色背景（如果不使用图片）
    };
  };
};
```

### 📦 可用主题

- **chili** - 现代简洁风格（当前使用）
- **elarun** - 蓝色渐变风格
- **maya** - 深色优雅风格
- **breath** - 动态呼吸效果

### 💡 示例：下载网络壁纸

```bash
# 下载 Unsplash 壁纸作为 SDDM 背景
curl -o /etc/nixos/wallpapers/sddm-background.jpg \
  "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=1920"

# 然后重建系统
sudo nixos-rebuild switch --flake .#nixos
```

### ⚠️ 注意事项

1. **壁纸尺寸**：建议使用 1920x1080 或更高分辨率的图片
2. **文件格式**：JPG 或 PNG 格式
3. **文件位置**：必须放在 `/etc/nixos/wallpapers/` 目录下
4. **重建系统**：修改壁纸后需要重新构建系统才能生效
5. **Wayland 支持**：已启用 SDDM Wayland 模式，确保与 Plasma 6 兼容

### 🔧 故障排除

**Q: 壁纸不显示？**  
A: 检查以下几点：
- 确认壁纸文件路径正确：`/etc/nixos/wallpapers/sddm-background.jpg`
- 确认文件格式是 JPG 或 PNG
- 查看 SDDM 日志：`journalctl -u display-manager -b`
- 尝试切换主题：修改 `Theme.Current` 为其他值

**Q: 如何恢复默认壁纸？**  
A: 删除或重命名自定义壁纸文件，系统会自动使用 KDE 默认壁纸：
```bash
mv /etc/nixos/wallpapers/sddm-background.jpg \
   /etc/nixos/wallpapers/sddm-background.jpg.backup
sudo nixos-rebuild switch --flake .#nixos
```

### 📚 参考资料

- [NixOS SDDM 模块文档](https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=services.displayManager.sddm)
- [SDDM 官方主题库](https://github.com/sddm/sddm-themes)
- [KDE Plasma 壁纸](https://store.kde.org/browse?cat=128&ord=latest)

---

## 🎮 Clash TUN 模式

### 启动 TUN 模式

```bash
# 启动 TUN 模式 (需要 sudo)
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

## 🤖 MCP Server NixOS（灵码 AI 助手）

### 快速启动

配置已完成！只需重启 VSCode 或重新加载窗口即可。

```bash
# 确保 Clash TUN 模式运行（如果需要访问 PyPI）
sudo clash-tun

# 重启 VSCode 后按 Ctrl+Shift+P，选择 "Developer: Reload Window"
```

### 配置位置

- **包装脚本**: `/etc/nixos/scripts/mcp-nixos-wrapper.sh`
- **VSCode 配置**: 已在 `settings.json` 中自动配置

### 常见问题

**Q: 首次启动很慢怎么办？**  
A: 首次运行需要下载 Python 依赖包（约 1-2 分钟），请耐心等待

**Q: 提示连接超时？**  
A: 确保 Clash TUN 模式已启动：`sudo clash-tun`

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

---

## 🎯 设计原则

### 简单至上

1. **放弃"伪动态"**: 不再尝试在 Nix 代码中做运行时检测
2. **显式优于隐式**: 硬件配置一目了然
3. **修改即生效**: 无需理解复杂的 Flakes 求值机制

### 模块化架构

1. **硬件解耦**: CPU/GPU 配置完全分离
2. **职责分明**: 系统级 vs 用户级配置清晰
3. **类型安全**: 通过 `detection.nix` 提供基本检查

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

## 🔧 如何切换硬件配置

### 1. 编辑 [`configuration.nix`](configuration.nix) 第 6-20 行

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

#### 方式 1：使用 Flakes（推荐，支持 Home Manager）
```bash
cd /etc/nixos
sudo nixos-rebuild switch --flake .#nixos
```

#### 方式 2：直接使用 configuration.nix（无 Flakes）
```bash
cd /etc/nixos
sudo nixos-rebuild switch
```

⚠️ **注意**：方式 2 需要你有 `/etc/nixos/configuration.nix` 的传统 NixOS 安装。

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

## 💡 Shell 别名（已配置）

你的 Fish Shell 已经有现成的别名：

```bash
# 使用 Flakes 重建（推荐）
rebuild-flake

# 或简短版本
nrs --flake .#nixos

# 完整命令
sudo nixos-rebuild switch --flake .#nixos
```

## 📋 当前配置

查看当前生效的硬件配置：
```bash
# 查看导入的 CPU 配置
grep "cpu/" /etc/nixos/configuration.nix

# 查看导入的 GPU 配置
grep "gpu/" /etc/nixos/configuration.nix
```

## ❗ 注意事项

1. **必须指定有效的文件路径**：如果 `.nix` 文件不存在，构建会失败
2. **建议重启**：切换硬件配置后最好重启，确保内核固件正确加载
3. **Lock 文件**：`flake.lock` 会锁定所有依赖版本，确保可复现性
4. **Home Manager**：仍然通过 Flakes 集成，建议使用 `--flake` 参数

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
- ✅ 支持 `sudo nixos-rebuild switch` 直接构建
