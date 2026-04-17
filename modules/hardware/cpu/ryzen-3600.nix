{ config, lib, pkgs, ... }:

{
  # ✅ 启用 CPU 频率和温度传感器支持
  boot.kernelModules = [ 
    "acpi-cpufreq"
    "k10temp"       # ✅ 新增：AMD CPU 温度传感器
  ];
  
  boot.kernelParams = [
    "amd_pstate=active"
    "processor.max_cstate=5"
    "init_on_alloc=1"
    "pcie_aspm=off"  # ✅ 改为保守设置，提高稳定性
    "transparent_hugepage=madvise"
    "numa_balancing=1"
    
    # ✅ HDMI/DP 音频输出（与 GPU 模块协同设置）
    "amdgpu.audio=1"
    
    # ✅ Linux 7.0 新增：启用 EEVDF 调度器优化
    "sched_schedstats=0"  # 禁用调度统计以提升性能
  ];
  
  powerManagement = {
    powertop.enable = true;
    # ✅ 统一使用 schedutil（现代内核推荐）
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };
  
  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;
    "kernel.sched_migration_cost_ns" = lib.mkForce 50000;
    "kernel.sched_wakeup_granularity_ns" = lib.mkForce 1000000;  # Linux 7.0 调度器优化
    
    # 内存优化 - Ryzen 3000 系列优化的值
    "vm.swappiness" = lib.mkForce 10;
    "vm.vfs_cache_pressure" = lib.mkForce 50;
    "vm.dirty_ratio" = lib.mkForce 20;
    "vm.dirty_background_ratio" = lib.mkForce 10;
    
    # Zen 2 架构可以禁用 PTI
    "kernel.page-table-isolation" = lib.mkForce 0;
    "vm.transparent_hugepage_defrag" = lib.mkForce 0;
    
    # ✅ Linux 7.0 内存管理优化
    "vm.compaction_proactiveness" = lib.mkForce 20;  # 主动内存压缩
  };
  
  # ✅ 温度监控工具（与 GPU 模块共享）
  environment.systemPackages = with pkgs; [
    lm_sensors  # 传感器读取工具
  ];
}