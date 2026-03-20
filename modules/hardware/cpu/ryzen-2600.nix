# { config, lib, pkgs, ... }:

# {
#   config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-2600") {
#     hardware.cpu.model = "ryzen-2600";
    
#     boot.kernelParams = [
#       # "amd_pstate=active"  # 新内核可能有问题，先禁用
#       "processor.max_cstate=5"
#     ];
    
#     powerManagement.powertop.enable = true;
#   };
# }
{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-2600") {
    hardware.cpu.model = "ryzen-2600";
    
    boot.kernelParams = [
      # CPU 频率和电源管理
      "amd_pstate=active"  # Zen+ 支持 amd_pstate，启用主动模式
      "processor.max_cstate=5"  # 允许深度 C-State 节能
      "init_on_alloc=1"  # 安全优化
      
      # Ryzen 专属优化
      # "pcie_aspm=performance"  # PCIe ASPM 性能模式
      
      # 内存和缓存优化
      "transparent_hugepage=madvise"  # 透明大页优化
      "numa_balancing=1"  # NUMA 自动平衡（Ryzen 是多 Die 设计）
    ];
    
    # 电源管理优化
    powerManagement = {
      powertop.enable = true;
      cpuFreqGovernor = lib.mkDefault "performance";  # 高性能模式
    };
    
    # 系统优化
    boot.kernel.sysctl = {
      # CPU 调度优化
      "kernel.sched_autogroup_enabled" = lib.mkDefault 1;  # 启用自动任务组
      "kernel.sched_migration_cost_ns" = lib.mkDefault 50000;  # 调度迁移成本
      
      # 内存优化
      "vm.swappiness" = lib.mkDefault 10;  # 减少 swap 使用
      "vm.vfs_cache_pressure" = lib.mkDefault 50;  # 降低 VFS 缓存压力
      "vm.dirty_ratio" = lib.mkDefault 20;  # 提高脏页比例
      "vm.dirty_background_ratio" = lib.mkDefault 10;
      
      # AMD Zen+ 专属
      "kernel.page-table-isolation" = lib.mkDefault 0;  # 禁用 PTI（Zen+ 有硬件缓解）
    };
  };
}