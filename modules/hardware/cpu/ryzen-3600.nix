{ lib, pkgs, ... }:

{
  # ✅ 启用 CPU 频率和温度传感器支持
  boot.kernelModules = [
    "k10temp" # ✅ 新增：AMD CPU 温度传感器
  ];

  boot.kernelParams = [
    "amd_pstate=active"
    "processor.max_cstate=5"
    "init_on_alloc=1"
    "transparent_hugepage=madvise"

    # ✅ HDMI/DP 音频输出（与 GPU 模块协同设置）
    "amdgpu.audio=1"

    # ✅ Linux 7.0 新增：启用 EEVDF 调度器（取代 CFS）
    "schedstats=disable"
    "pti=off" # Zen 2 不受 Meltdown 影响，禁用页表隔离以减少性能开销
  ];

  # ✅ 只启用 powertop 服务，不再通过 powerManagement 配置 CPU 调频器
  powerManagement.powertop.enable = true;

  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;
    "kernel.sched_migration_cost_ns" = lib.mkForce 50000;

    # 内存优化 - Ryzen 3000 系列优化的值
    "vm.swappiness" = lib.mkForce 10;
    "vm.vfs_cache_pressure" = lib.mkForce 50;

    # NUMA 内存平衡
    "kernel.numa_balancing" = lib.mkForce 1;
  };

   # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 3600 优化版
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

  # ✅ 温度监控工具（与 GPU 模块共享）
  environment.systemPackages = with pkgs; [
    lm_sensors # 传感器读取工具
  ];
}
