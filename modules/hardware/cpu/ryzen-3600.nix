{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-3600" || config.hardware.cpu.model == "ryzen-3600") {
    hardware.cpu.model = "ryzen-3600";
    
    boot.kernelParams = [
      "amd_pstate=active"
      "processor.max_cstate=5"
      "init_on_alloc=1"
      "pcie_aspm=performance"
      "transparent_hugepage=madvise"
      "numa_balancing=1"
    ];
    
    powerManagement = {
      powertop.enable = true;
      cpuFreqGovernor = lib.mkDefault "performance";
    };
    
    boot.kernel.sysctl = {
      "kernel.sched_autogroup_enabled" = lib.mkDefault 1;
      "kernel.sched_migration_cost_ns" = lib.mkDefault 50000;
      "vm.swappiness" = lib.mkDefault 10;
      "vm.vfs_cache_pressure" = lib.mkDefault 50;
      "vm.dirty_ratio" = lib.mkDefault 20;
      "vm.dirty_background_ratio" = lib.mkDefault 10;
    };
  };
}