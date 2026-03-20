# { config, lib, pkgs, ... }:

# {
#   config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-1600x") {
#     hardware.cpu.model = "ryzen-1600x";
    
#     boot.kernelParams = [
#       "amd_pstate=active"
#       "processor.max_cstate=5"
#     ];
    
#     powerManagement.powertop.enable = true;
    
#     # Deleted: nix.settings.max-jobs = 6;
#   };
# }

{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-1600x") {
    hardware.cpu.model = "ryzen-1600x";
    
    boot.kernelParams = [
      # 第一代 Ryzen 优化
      # "amd_pstate=active"  # 第一代 Ryzen 不支持，使用 acpi-cpufreq
      "processor.max_cstate=5"
      "init_on_alloc=1"
      
      # 第一代 Ryzen 特殊优化
      "pcie_aspm=off"  # 第一代 Ryzen ASPM 不稳定，建议关闭
      
      # 内存优化（第一代 Ryzen 对内存时序敏感）
      "transparent_hugepage=madvise"
      "numa_balancing=1"
    ];
    
    powerManagement = {
      powertop.enable = true;
      cpuFreqGovernor = lib.mkDefault "ondemand";  # 按需调频（更适合第一代）
    };
    
    boot.kernel.sysctl = {
      # 调度优化
      "kernel.sched_autogroup_enabled" = 1;
      "kernel.sched_migration_cost_ns" = 50000;
      
      # 内存优化
      "vm.swappiness" = 10;
      "vm.vfs_cache_pressure" = 50;
      "vm.dirty_ratio" = 20;
      "vm.dirty_background_ratio" = 10;
      
      # 安全优化（第一代 Ryzen 需要 PTI）
      "kernel.page-table-isolation" = 1;  # 启用 PTI
    };
  };
}