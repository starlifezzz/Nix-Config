{ config, lib, pkgs, ... }:

{
  # ✅ CPU 频率调节模块 - Ryzen 1000 系列必需
  boot.kernelModules = [ 
    "acpi-cpufreq"
    "k10temp"       # ✅ 新增：AMD CPU 温度传感器
  ];
  
  boot.kernelParams = [
    "processor.max_cstate=5"
    "init_on_alloc=1"
    "pcie_aspm=off"
    "transparent_hugepage=madvise"
    "numa_balancing=1"
    
    # ✅ 新增：HDMI/DP 音频输出
    "amdgpu.audio=1"
k    
    # ✅ Linux 7.0 新增：启用 EEVDF 调度器优化
    "sched_schedstats=0"  # 禁用调度统计以提升性能
  ];
  
  powerManagement.powertop.enable = true;

  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;
    "kernel.sched_migration_cost_ns" = lib.mkForce 100000;
    "kernel.sched_wakeup_granularity_ns" = lib.mkForce 1000000;  # Linux 7.0 调度器优化
    
    "vm.swappiness" = lib.mkForce 15;  # 8GB 内存保持较高值
    "vm.vfs_cache_pressure" = lib.mkForce 50;
    "vm.dirty_ratio" = lib.mkForce 15;
    "vm.dirty_background_ratio" = lib.mkForce 10;
    "kernel.page-table-isolation" = lib.mkForce 1;  # Zen 需要 PTI
    
    # ✅ Linux 7.0 内存管理优化
    "vm.compaction_proactiveness" = lib.mkForce 20;  # 主动内存压缩
  };
  
  # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 1600X 专属启用
  # ═══════════════════════════════════════════════════════════
  # 适用于低内存场景 (如 8GB),提供额外的压缩交换空间
  services.zram-generator = {
    enable = true;
    settings = {
      # zram-generator 使用 systemd 配置格式
      # 参考：https://github.com/systemd/systemd/blob/main/src/zram-generator/zram-generator.conf.example
      "zram0" = {
        compression-algorithm = "zstd";  # Zstandard 压缩算法 (高压缩比)
        zram-size = "ram * 0.9";  # 使用 90% 的物理内存作为 zram
        swap-priority = 100;  # 高于普通 swap 的优先级
      };
    };
  };
  
  # ✅ 新增：温度监控工具
  environment.systemPackages = with pkgs; [
    lm_sensors  # 传感器读取工具
  ];
}