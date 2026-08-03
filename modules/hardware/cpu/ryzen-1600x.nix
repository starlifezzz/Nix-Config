{ lib, pkgs, ... }:

{
  # ✅ CPU 频率调节模块 - Ryzen 1000 系列必需
  boot.kernelModules = [
    "acpi-cpufreq"
    "k10temp" # ✅ 新增：AMD CPU 温度传感器
  ];

  boot.kernelParams = [
    "processor.max_cstate=5"
    "init_on_alloc=1"
    # "pcie_aspm=off"
    # ✅ 新增：HDMI/DP 音频输出
    "amdgpu.audio=1"

    # ✅ Linux 7.0 新增：启用 EEVDF 调度器（取代 CFS）
    "schedstats=disable"
    "pti=on"
  ];

  powerManagement.powertop.enable = true;

  boot.kernel.sysctl = {
    "kernel.sched_autogroup_enabled" = lib.mkForce 1;
    "kernel.sched_migration_cost_ns" = lib.mkForce 100000;
    "vm.swappiness" = lib.mkForce 15; # 8GB 内存保持较高值
    "vm.vfs_cache_pressure" = lib.mkForce 50;
    "kernel.numa_balancing" = lib.mkForce 1;
  };

  # ═══════════════════════════════════════════════════════════
  # Zram 虚拟内存配置 - Ryzen 1600X 专属启用
  # ═══════════════════════════════════════════════════════════
  # 适用于低内存场景 (如 8GB),提供额外的压缩交换空间
  services.zram-generator = {
    enable = true;
    settings = {
      # zram-generator 使用 systemd 配置格式
      # 参考：https://github.com/systemd/systemd/blob/main/src/zram-generator/zram-generator.conf.example
      "zram0" = {
        compression-algorithm = "zstd"; # Zstandard 压缩算法 (高压缩比)
        zram-size = "ram * 0.9"; # 使用 90% 的物理内存作为 zram
        swap-priority = 100; # 高于普通 swap 的优先级
      };
    };
  };

  # ✅ 新增：温度监控工具
  environment.systemPackages = with pkgs; [
    lm_sensors # 传感器读取工具
  ];
}
