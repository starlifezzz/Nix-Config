{ config, lib, pkgs, ... }:

{
  # ✅ 启用 CPU 频率和温度传感器支持
  boot.kernelModules = [ 
    "acpi-cpufreq"  # CPU 频率调节模块
    "k10temp"       # ✅ 新增：AMD CPU 温度传感器
  ];
  
  # ✅ CPU 频率和电源管理 - NixOS 官方推荐设置
  boot.kernelParams = [
    "amd_pstate=active"  # Zen+ 支持 amd_pstate，启用主动模式
    
    # ✅ 新增：HDMI/DP 音频输出
    "amdgpu.audio=1"
    
    # 安全优化
    "init_on_alloc=1"
    
    # 内存和缓存优化
    "transparent_hugepage=madvise"  # 透明大页优化
    "numa_balancing=1"  # NUMA 自动平衡（Ryzen 是多 Die 设计）
  ];
  
  # 电源管理优化
  powerManagement = {
    powertop.enable = true;
    # ✅ 统一使用 schedutil（现代内核推荐）
    cpuFreqGovernor = lib.mkDefault "schedutil";
  };
  
  # 系统优化
  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;  # 启用自动任务组
    "kernel.sched_migration_cost_ns" = lib.mkForce 50000;  # 调度迁移成本
    
    # 内存优化 - ✅ 修正为 16GB 内存匹配的值
    "vm.swappiness" = lib.mkForce 1;  # ✅ 从 12 改为 1（16GB 内存应最小化 swap）
    "vm.vfs_cache_pressure" = lib.mkForce 50;  # 降低 VFS 缓存压力
    "vm.dirty_ratio" = lib.mkForce 20;  # 提高脏页比例
    "vm.dirty_background_ratio" = lib.mkForce 10;
    
    # AMD Zen+ 专属
    "kernel.page-table-isolation" = lib.mkForce 0;  # Zen+ 有硬件缓解，可以禁用 PTI 提升性能
    "vm.transparent_hugepage_defrag" = lib.mkForce 0;  # 禁用透明大页碎片整理
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
        zram-size = "ram * 0.5";  # 使用 90% 的物理内存作为 zram
        swap-priority = 100;  # 高于普通 swap 的优先级
      };
    };
  };
  
  # ✅ 新增：温度监控工具
  environment.systemPackages = with pkgs; [
    lm_sensors  # 传感器读取工具
  ];
}