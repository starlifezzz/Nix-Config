{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-3600") {
    hardware.cpu.model = "ryzen-3600";
    
    boot.kernelParams = [
      "amd_pstate=active"
      "processor.max_cstate=5"
      "init_on_alloc=1"
      "pcie_aspm=off"  # ✅ 改为保守设置，提高稳定性
      "transparent_hugepage=madvise"
      "numa_balancing=1"

    ];
    
    powerManagement = {
      powertop.enable = true;
      cpuFreqGovernor = lib.mkDefault "performance";
    };
    
    boot.kernel.sysctl = {
      # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
      "kernel.sched_autogroup_enabled" = lib.mkForce 1;
      "kernel.sched_migration_cost_ns" = lib.mkForce 50000;
      
      # 内存优化 - Ryzen 3000 系列优化的值
      "vm.swappiness" = lib.mkForce 10;
      "vm.vfs_cache_pressure" = lib.mkForce 50;
      "vm.dirty_ratio" = lib.mkForce 20;
      "vm.dirty_background_ratio" = lib.mkForce 10;
      
      # Zen 2 架构可以禁用 PTI
      "kernel.page-table-isolation" = lib.mkForce 0;
      "vm.transparent_hugepage_defrag" = lib.mkForce 0;  # ✅ 新增
    };
  };
}