{ lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # SSD 优化模块
  # ═══════════════════════════════════════════════════════════
  
  # SSD 优化 - 定期 TRIM
  services.fstrim = {
    enable = true;
    # ═══════════════════════════════════════════════════════════
    # ✅ 优化TRIM频率 - 每周一次而非每日，减少SSD写入
    # ═══════════════════════════════════════════════════════════
    interval = "weekly";
  };
  
  # 内核参数优化 - SSD 专用优化
  boot.kernel.sysctl = {
    # SSD 优化：禁用交换预读
    "vm.page-cluster" = lib.mkDefault 0;
    
    # Linux 7.0 内存管理优化（针对SSD）
    "vm.dirty_ratio" = 15; # 脏页占总内存比例上限降至15%
    "vm.dirty_background_ratio" = 5; # 后台写回触发比例降至5%
    "vm.dirty_expire_centisecs" = 3000; # 脏页过期时间设为30秒
    "vm.dirty_writeback_centisecs" = 500; # 脏页写回间隔设为5秒
  };
}