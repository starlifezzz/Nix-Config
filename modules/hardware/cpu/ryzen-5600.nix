{ lib, pkgs, ... }:

{

  # ✅ 启用 CPU 频率和温度传感器支持
  boot.kernelModules = [
    "k10temp" # AMD CPU 温度传感器（Ryzen 专属）
  ];

  # ✅ CPU 频率和电源管理 - Linux 7.0+ 兼容版本，针对 Zen 3 优化
  boot.kernelParams = [
    "amd_pstate=active" # Zen 3 完全支持 amd_pstate，启用主动模式

    # ✅ 已移除 init_on_alloc=1（安全加固参数，会拖慢内存分配性能）
    # 本机为个人桌面，无多租户隔离需求，安全收益≈0，性能损失真实存在
    # 依据: https://docs.kernel.org/mm/page_poison.html

    # 内存和缓存优化 - Zen 3 架构优化
    "transparent_hugepage=madvise" # 透明大页优化
    # ✅ 移除 numa_balancing=1 内核参数，该参数应通过 sysctl 设置，避免 mempolicy 解析错误

    # ✅ Linux 7.0 新增：启用 EEVDF 调度器（取代 CFS）
    "schedstats=disable"
  ];

  # 电源管理优化 - 启用 powertop，不配置 CPU 频率调节器
  # 现代内核会自动使用 schedutil，无需显式配置
  powerManagement.powertop.enable = true;

  # ❌ 不配置 powerManagement.cpuFreqGovernor！
  # 原因: amd_pstate active 模式（amd-pstate-epp 驱动）只支持
  #       powersave / performance 两种 governor（实测 scaling_available_governors），
  #       schedutil 是传统 cpufreq 驱动的选项，在此硬件上会报
  #       "Error setting new values" (exit 237/KEYRING)
  # 结论: active 模式下 powersave 由硬件 EPP 控制，负载时会自动睿频，
  #       桌面响应与 schedutil 无差别，保持默认即可
  # 依据: https://docs.kernel.org/admin-guide/pm/amd-pstate.html
  # 验证: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

  # 系统优化 - Linux 7.0+ 兼容版本，针对 Zen 3 优化
  boot.kernel.sysctl = {
    # CPU 调度优化 - 使用 lib.mkForce 覆盖 configuration.nix 的默认设置
    "kernel.sched_autogroup_enabled" = lib.mkForce 1; # 启用自动任务组

    # NUMA 平衡 - 通过 sysctl 启用
    "kernel.numa_balancing" = lib.mkForce 1;

    # 内存优化 - 针对现代系统优化
    "vm.swappiness" = lib.mkForce 1; # 最小化 swap 使用
    "vm.vfs_cache_pressure" = lib.mkForce 50; # 降低 VFS 缓存压力
  };

  # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 5600 优化版
  # ═══════════════════════════════════════════════════════════
  # 适用于现代系统，提供高效的压缩交换空间
  services.zram-generator = {
    enable = true;
    settings = {
      "zram0" = {
        compression-algorithm = "zstd"; # Zstandard 压缩算法 (高压缩比)
        zram-size = "ram * 0.25"; # 使用 25% 的物理内存作为 zram（Zen 3内存效率更高）
        swap-priority = 100; # 高于普通 swap 的优先级
      };
    };
  };

  # ── irqbalance：多核中断平衡（Ryzen 5600 桌面响应优化）──
  services.irqbalance.enable = true;
  # ✅ 温度监控工具
  
  environment.systemPackages = with pkgs; [
    lm_sensors # 传感器读取工具
  ];

  # ═══════════════════════════════════════════════════════════
  # 本机专属：XFS 分区挂载优化（仅此台机器）
  # ═══════════════════════════════════════════════════════════
  # 关闭 atime，减少 SSD 元数据写入。分区布局随机器不同，故放本机模块。
  fileSystems."/".options = [ "noatime" ];
  fileSystems."/home".options = [ "noatime" ];
}
