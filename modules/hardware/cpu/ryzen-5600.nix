{ config, lib, pkgs, ... }:

{

    # ✅ 启用 CPU 频率和温度传感器支持
  boot.kernelModules = [ 
    "acpi-cpufreq"  # CPU 频率调节模块
    "k10temp"       # ✅ 新增：AMD CPU 温度传感器
    "iwlwifi"       # ✅ Intel WiFi 驱动模块（必需）
    "iwlmvm"        # ✅ Intel WiFi 管理模块（必需）
  ];
  
  # ✅ Initrd 配置 - 确保 WiFi 驱动在启动早期可用
  boot.initrd.availableKernelModules = [ "iwlwifi" "iwlmvm" ];
  
  # ✅ 蓝牙支持 - Intel Wireless-AC 3168包含蓝牙功能
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # 开机时自动开启蓝牙
  };
  # ✅ CPU 频率和电源管理 - Linux 7.0+ 兼容版本，针对 Zen 3 优化
  boot.kernelParams = [
    "amd_pstate=active"  # Zen 3 完全支持 amd_pstate，启用主动模式
    
    # 安全优化
    "init_on_alloc=1"
    
    # 内存和缓存优化 - Zen 3 架构优化
    "transparent_hugepage=madvise"  # 透明大页优化
    # ✅ 移除 numa_balancing=1 内核参数，该参数应通过 sysctl 设置，避免 mempolicy 解析错误
    
    # ✅ Linux 7.0+ 新增：启用 EEVDF 调度器相关优化
    "sched_schedstats=0"  # 禁用调度统计以提升性能
  ];
  
  # 电源管理优化 - 启用 powertop，不配置 CPU 频率调节器
  # 现代内核会自动使用 schedutil，无需显式配置
  powerManagement.powertop.enable = true;

  # 系统优化 - Linux 7.0+ 兼容版本，针对 Zen 3 优化
  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;  # 启用自动任务组
    
    # NUMA 平衡 - 通过 sysctl 启用
    "kernel.numa_balancing" = lib.mkForce 1;
    
    # 内存优化 - 针对现代系统优化
    "vm.swappiness" = lib.mkForce 1;  # 最小化 swap 使用
    "vm.vfs_cache_pressure" = lib.mkForce 50;  # 降低 VFS 缓存压力
    "vm.dirty_ratio" = lib.mkForce 20;  # 提高脏页比例
    "vm.dirty_background_ratio" = lib.mkForce 10;
    
    # ✅ Linux 7.0+ 内存管理优化
    "vm.compaction_proactiveness" = lib.mkForce 20;  # 主动内存压缩
    
    # ✅ 移除：kernel.sched_migration_cost_ns 和 kernel.sched_wakeup_granularity_ns 
    # 在Linux 7.0中已重命名或移除，保留会导致systemd-sysctl警告
  };
  
  # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 5600 优化版
  # ═══════════════════════════════════════════════════════════
  # 适用于现代系统，提供高效的压缩交换空间
  services.zram-generator = {
    enable = true;
    settings = {
      "zram0" = {
        compression-algorithm = "zstd";  # Zstandard 压缩算法 (高压缩比)
        zram-size = "ram * 0.25";  # 使用 25% 的物理内存作为 zram（Zen 3内存效率更高）
        swap-priority = 100;  # 高于普通 swap 的优先级
      };
    };
  };
  
  # ✅ 温度监控工具
  environment.systemPackages = with pkgs; [
    lm_sensors  # 传感器读取工具
  ];
}