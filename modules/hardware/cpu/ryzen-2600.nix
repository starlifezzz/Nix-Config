{ config, lib, pkgs, ... }:

{
  # ✅ CPU 频率和电源管理 - NixOS 官方推荐设置
  boot.kernelParams = [
    "amd_pstate=active"  # Zen+ 支持 amd_pstate，启用主动模式
    
    # 安全优化
    "init_on_alloc=1"
    
    # Ryzen 专属优化 - 保守设置
    # 移除 pcie_aspm=performance 和 processor.max_cstate=5
    # 让内核自动管理 ASPM 和 C-State，通常更稳定
    # 避免可能的 USB 设备连接问题
    
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
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;  # 启用自动任务组
    "kernel.sched_migration_cost_ns" = lib.mkForce 50000;  # 调度迁移成本
    
    # 内存优化 - Zen+ 优化的值
    "vm.swappiness" = lib.mkForce 12;  # 减少 swap 使用
    "vm.vfs_cache_pressure" = lib.mkForce 50;  # 降低 VFS 缓存压力
    "vm.dirty_ratio" = lib.mkForce 20;  # 提高脏页比例
    "vm.dirty_background_ratio" = lib.mkForce 10;
    
    # AMD Zen+ 专属
    # 使用 lib.mkForce 确保覆盖 configuration.nix 中的默认设置
    "kernel.page-table-isolation" = lib.mkForce 0;  # Zen+ 有硬件缓解，可以禁用 PTI 提升性能
    "vm.transparent_hugepage_defrag" = lib.mkForce 0;  # ✅ 新增
  };
}