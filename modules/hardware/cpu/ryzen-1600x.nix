{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-1600x") {
    hardware.cpu.model = "ryzen-1600x";
    
    # ✅ CPU 频率调节模块 - Ryzen 1000 系列必需
    boot.kernelModules = [ "acpi-cpufreq" ];
    
    boot.kernelParams = [
      "processor.max_cstate=5"
      "init_on_alloc=1"
      "pcie_aspm=off"
      "transparent_hugepage=madvise"
      "numa_balancing=1"
    ];
    
    powerManagement = {
      powertop.enable = true;
      cpuFreqGovernor = lib.mkForce "ondemand";
    };
    
    boot.kernel.sysctl = {
      "kernel.sched_autogroup_enabled" = lib.mkForce 1;
      "kernel.sched_migration_cost_ns" = lib.mkForce 100000;
      "vm.swappiness" = lib.mkForce 15;
      "vm.vfs_cache_pressure" = lib.mkForce 50;
      "vm.dirty_ratio" = lib.mkForce 15;
      "vm.dirty_background_ratio" = lib.mkForce 10;
      "kernel.page-table-isolation" = lib.mkForce 1;
    };
  };
}