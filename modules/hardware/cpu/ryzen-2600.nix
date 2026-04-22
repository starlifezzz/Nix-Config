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
  
  # ✅ 固件配置 - 包含 Intel WiFi 固件
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.enableRedistributableFirmware = true;
  
  # ✅ 蓝牙支持 - Intel Wireless-AC 3168包含蓝牙功能
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # 开机时自动开启蓝牙
  };
  
  # ✅ CPU 频率和电源管理 - Linux 7.0 兼容版本
  boot.kernelParams = [
    "amd_pstate=active"  # Zen+ 支持 amd_pstate，启用主动模式
    
    # 安全优化
    "init_on_alloc=1"
    
    # 内存和缓存优化
    "transparent_hugepage=madvise"  # 透明大页优化
    "numa_balancing=1"  # NUMA 自动平衡（Ryzen 是多 Die 设计）
    
    # ✅ Linux 7.0 新增：启用 EEVDF 调度器（取代 CFS）
    "sched_schedstats=0"  # 禁用调度统计以提升性能（除非需要调试）
  ];
  
  # 电源管理优化
  powerManagement = {
    powertop.enable = true;
    # ✅ 统一使用 schedutil（现代内核推荐）
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };
  
  # 系统优化 - Linux 7.0 兼容版本
  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;  # 启用自动任务组
    "kernel.sched_migration_cost_ns" = lib.mkForce 50000;  # 调度迁移成本
    
    # ✅ Linux 7.0 调度器优化
    "kernel.sched_wakeup_granularity_ns" = lib.mkForce 1000000;  # 唤醒粒度
    
    # 内存优化 - ✅ 修正为 16GB 内存匹配的值
    "vm.swappiness" = lib.mkForce 1;  # ✅ 从 12 改为 1（16GB 内存应最小化 swap）
    "vm.vfs_cache_pressure" = lib.mkForce 50;  # 降低 VFS 缓存压力
    "vm.dirty_ratio" = lib.mkForce 20;  # 提高脏页比例
    "vm.dirty_background_ratio" = lib.mkForce 10;
    
    # AMD Zen+ 专属
    "kernel.page-table-isolation" = lib.mkForce 0;  # Zen+ 有硬件缓解，可以禁用 PTI 提升性能
    "vm.transparent_hugepage_defrag" = lib.mkForce 0;  # 禁用透明大页碎片整理
    
    # ✅ Linux 7.0 内存管理优化
    "vm.compaction_proactiveness" = lib.mkForce 20;  # 主动内存压缩
  };

    # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 2600 专属启用
  # ═══════════════════════════════════════════════════════════
  # 适用于低内存场景 (如 16GB),提供额外的压缩交换空间
  services.zram-generator = {
    enable = true;
    settings = {
      # zram-generator 使用 systemd 配置格式
      # 参考：https://github.com/systemd/systemd/blob/main/src/zram-generator/zram-generator.conf.example
      "zram0" = {
        compression-algorithm = "zstd";  # Zstandard 压缩算法 (高压缩比)
        zram-size = "ram * 0.5";  # 使用 50% 的物理内存作为 zram
        swap-priority = 100;  # 高于普通 swap 的优先级
      };
    };
  };
  
  # ✅ 温度监控工具（与 GPU 模块共享，避免重复安装）
  environment.systemPackages = with pkgs; [
    lm_sensors  # 传感器读取工具
  ];
}