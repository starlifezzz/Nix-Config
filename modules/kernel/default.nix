# 内核相关配置

{ lib, pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10;
        consoleMode = "max";
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_zen;

    kernelParams = [
      "loglevel=3"
      "udev.log_level=3"

      # ═══════════════════════════════════════════════════════════
      # NVMe SSD 优化 - 解决 SUBNQN 警告和性能问题
      # ═══════════════════════════════════════════════════════════
      "nvme_core.default_ps_max_latency_us=0" # 禁用电源管理以提高性能
      "nvme_core.multipath=N" # 禁用多路径（单设备）
      "nvme_core.io_timeout=4294967295" # 最大IO超时

      # ═══════════════════════════════════════════════════════════
      # USB 设备稳定性优化 - NixOS 官方推荐设置
      # ═══════════════════════════════════════════════════════════
      "usbcore.autosuspend=-1" # 禁用 USB 自动挂起
      "usbcore.usbfs_memory_mb=1024" # USBFS 内存
      
      "spectre_v2=on"
      "acpi_enforce_resources=lax"
      "zswap.enabled=1"
      "zswap.compressor=zstd"
      "zswap.max_pool_percent=20"
    ];

    # 内核模块
    kernelModules = [
      "xpad" # Xbox 手柄驱动
      "ntsync" # NTSYNC内核驱动 - 提升Windows应用程序多线程同步性能
    ];

    # 黑名单模块 - 防止与手柄冲突
    blacklistedKernelModules = [
      "hid_nintendo" # 禁止 Switch 手柄驱动（避免与北通鲲鹏 20 冲突）
    ];

    # 内核参数优化 - 仅保留桌面环境必要的优化
    kernel.sysctl = {
      # 内存管理 - 使用 lib.mkDefault 允许硬件模块覆盖
      "vm.swappiness" = lib.mkDefault 1;

      # 文件系统优化
      "fs.inotify.max_user_watches" = 524288;
      "fs.file-max" = 2097152;

      "kernel.perf_event_paranoid" = 0;

      # ✅ Linux 7.0 容器和虚拟化性能优化
      "kernel.keys.root_maxbytes" = 25000000;
      "kernel.keys.root_maxkeys" = 1000000;
    };

    tmp.useTmpfs = true; # 默认就是 50%，无需声明 tmpfsSize
  };
}
