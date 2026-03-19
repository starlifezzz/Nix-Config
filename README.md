# 🚀 NixOS 配置

<div align="center">

![NixOS](https://img.shields.io/badge/NixOS-25.11-blue?style=for-the-badge&logo=nixos)
![Plasma](https://img.shields.io/badge/Plasma-6-green?style=for-the-badge&logo=kde)
![Linux](https://img.shields.io/badge/Linux-Latest-yellow?style=for-the-badge&logo=linux)

**zhangchongjie个性化 NixOS 系统配置**

[📋 配置概览](#-配置概览) • [🖥️ 桌面环境](#-桌面环境) • [📦 已安装软件](#-已安装软件) • [⚙️ 系统优化](#-系统优化) • [🔧 快速开始](#-快速开始)

</div>

---

## 📋 配置概览

| 项目 | 配置 |
|------|------|
| **系统版本** | NixOS 25.11 |
| **桌面环境** | KDE Plasma 6 |
| **显示管理器** | SDDM (Breeze 主题) |
| **内核版本** | Linux Latest (最新稳定版) |
| **文件系统** | BTRFS |
| **主机名** | nixos |
| **用户** | zhangchongjie |
| **默认 Shell** | Fish |
| **时区** | Asia/Shanghai |
| **语言** | zh_CN.UTF-8 |

---

## 🖥️ 桌面环境

### 核心组件
- **窗口系统**: X11 + Wayland
- **桌面环境**: KDE Plasma 6
- **显示管理器**: SDDM
  - 主题：Breeze
  - 默认会话：Plasma
- **输入法**: Fcitx5
  - Rime 引擎
  - 中文拼音支持
  - 配置工具

### 多媒体支持
- **音频服务**: PipeWire + PulseAudio
- **蓝牙**: 已启用
- **打印服务**: 已禁用

---

## 📦 已安装软件

### 🔧 开发工具
- **VSCode** - 代码编辑器
- **Git** - 版本控制
- **Vim** - 文本编辑器
- **Zellij** - Terminal 多路复用器

### 🌐 网络应用
- **Firefox** - 浏览器
- **FlClash** - 代理客户端 (支持 TUN 模式)
- **KDE Connect** - 设备互联

### 🎮 游戏相关
- **Lutris** - 游戏平台
- **ProtonUp-Qt** - Proton 管理工具

### 🛠️ 系统工具
- **Alacritty** - GPU 加速终端
- **Neofetch** - 系统信息显示
- **Timeshift** - 系统备份
- **BleachBit** - 系统清理
- **Home Manager** - 用户配置管理

### 🎨 图形与媒体
- **FFmpeg** - 完整的音视频处理工具
- **Vulkan Tools** - Vulkan 图形工具
- **Radeontop** - AMD GPU 监控

### 📱 Flatpak 支持
- Flatpak 运行时已启用
- 自动字体配置

---

## ⚙️ 系统优化

### 🚀 性能优化

#### 内核参数

- TCP 拥塞控制：BBR
- TCP Fastopen：启用 (级别 3)
- 网络队列调度：FQ
- 内存交换策略：Swappiness = 1 (最小化 swap 使用)
- 页面表隔离：禁用 (AMD Ryzen 优化)

网络优化
TCP BBR 拥塞控制算法
FQ 队列调度器
增大网络缓冲区 (128MB)
DNS 服务器：119.29.29.29, 223.5.5.5
存储优化
BTRFS 文件系统
每周自动碎片整理
定期 scrub 检查
SSD TRIM 定期执行
自动存储优化
💾 内存管理
zRAM Swap
大小：50% 物理内存
压缩算法：ZSTD
优先级：100
交换策略
Swappiness: 1 (尽量避免使用 swap)
VFS 缓存压力：100
🔋 电源管理
CPU 频率调节: Performance 模式
AMD P-State: 可选启用
C-State: 限制在 C5
🎯 AMD GPU 优化
驱动: AMDGPU
IOMMU: Soft 模式
硬件加速:
VDPAU
VA-API
Vulkan
监控工具: Radeontop
🔧 Nix 配置
镜像源 (中国)
1. 清华大学镜像源
2. 中科大镜像源
3. 教育网镜像源
4. NixOS 官方缓存
实验特性
✅ Nix Command
✅ Flakes
垃圾回收
自动 GC: 每天执行
保留策略: 删除 3 天前的 derivations
自动优化存储: 启用
并行构建
最大任务数: Auto (根据 CPU 核心数)
构建核心数: 0 (无限制)
🌐 网络配置
防火墙
状态: 启用
允许 Ping: 是
开放端口:
TCP: 9090, 7897
UDP/TCP: 1714-1764 (KDE Connect)
代理服务
HTTP Proxy: http://127.0.0.1:7897
HTTPS Proxy: http://127.0.0.1:7897
No Proxy: 127.0.0.1, localhost, *.local
服务发现
Avahi/mDNS: 启用
systemd-resolved: 启用
👤 用户配置
主用户：zhangchongjie
用户组: networkmanager, wheel, flatpak, video, render, input, netraw
默认 Shell: Fish
Sudo 权限: 需要密码
系统程序
Fish Shell: 系统级启用
Firefox: 系统级启用
🔒 安全设置
Sudo: Wheel 组需要密码
Doas: 禁用
Core Dump: 禁用
防火墙沙箱: 启用
TUN 模块: 加载 (用于 FlClash)
📁 目录结构
/etc/nixos/
├── configuration.nix          # 主配置文件
├── hardware-configuration.nix # 硬件配置
├── flake.nix                  # Flake 配置
├── flake.lock                 # Flake 锁定文件
├── README.md                  # 本文件
├── .gitignore                 # Git 忽略规则
├── home/                      # Home Manager 配置
│   └── ...
└── modules/                   # 自定义模块
    ├── amd-gpu.nix           # AMD GPU 配置
    └── ...
🚀 快速开始
重建系统
bash
sudo nixos-rebuild switch --flake .
更新频道
bash
sudo nix-channel --update
垃圾回收
bash
sudo nix-collect-garbage -d
优化存储
bash
sudo nix-store --optimise
查看系统信息
bash
neofetch
🎨 特色功能
✨ 自动化维护
✅ 每日垃圾回收
✅ 每周 BTRFS scrub
✅ 定期 SSD TRIM
✅ 自动存储优化
🎯 性能调优
✅ AMD Ryzen 处理器优化
✅ AMD GPU 硬件加速
✅ BBR 网络加速
✅ zRAM 压缩交换
✅ SSD 专用优化
🔧 可定制性
✅ Flakes 支持
✅ Home Manager 集成
✅ 模块化配置
✅ 版本锁定
📝 注意事项
首次启动: 确保 BIOS 中启用了 EFI 启动
网络配置: 根据需要修改代理设置
用户密码: 首次启动后记得设置用户密码
Flatpak 仓库: 首次使用后添加 Flatpak 远程仓库
🛠️ 故障排查
常见问题
1. 无法启动
bash
# 进入恢复模式
nixos-rebuild boot --flake .
2. 网络问题
bash
# 重启 NetworkManager
sudo systemctl restart NetworkManager
3. 空间不足
bash
# 清理旧世代
sudo nix-collect-garbage --delete-older-than 7d
📚 参考资料
NixOS 官方文档
Nix 配置选项
Nixpkgs 软件包搜索
Home Manager
<div align="center">
Made with ❤️ using NixOS

如果这份配置对你有帮助，欢迎 Star ⭐

</div> 