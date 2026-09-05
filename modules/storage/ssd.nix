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

  # ═══════════════════════════════════════════════════════════
  # 日志不落盘 - journald 改为内存存储（volatile）
  # 目的：/var/log/journal 不再写 SSD，重启即清，零持久写入
  # 官方选项: https://search.nixos.org/options?query=services.journald.storage
  #          （storage = volatile 是官方选项，避免 extraConfig 追加造成
  #           与默认 Storage=persistent 重复定义）
  # 注意: 日志仅保留到本次关机，需持久审计时改回 persistent
  # 回滚: 删除此块后 rebuild
  # ═══════════════════════════════════════════════════════════
  services.journald.settings.Journal = {
    Storage = "volatile";
    RuntimeMaxUse = "128M";
  };

  # ═══════════════════════════════════════════════════════════
  # 高频缓存目录 tmpfs - 写内存不伤 SSD
  # 目的：~/.cache 高频读写（浏览器/Electron/plasmashell/uv 缓存）
  #       改为 tmpfs 后重启清空，SSD 零写入
  # ✅ 配置要点：
  #    - uid/gid 必带（否则属主 root 权限爆炸）
  #    - ⚠️ 禁加 noexec（uvx/npx 会在 .cache 下执行二进制）
  #    - nodev/nosuid 安全加固（缓存无需设备/suid）
  # 官方选项: https://search.nixos.org/options?query=fileSystems
  # 回滚: 删除此块后 rebuild
  # ═══════════════════════════════════════════════════════════
  fileSystems."/home/zhangchongjie/.cache" = {
    device = "tmpfs";
    fsType = "tmpfs";
    options = [
      "size=4G"
      "mode=0700"
      "uid=1000"
      "gid=100"
      "nodev"
      "nosuid"
    ];
  };

  # 内核参数优化 - SSD 专用优化
  boot.kernel.sysctl = {
    # SSD 优化：禁用交换预读
    "vm.page-cluster" = lib.mkDefault 0;

    # Linux 7.0 内存管理优化（针对SSD）
    # dirty_ratio 15→20：本机 31G 内存充裕，降低小写回频次
    # 作用: 更高的脏页阈值 → 更少小写回 → 减少 SSD 写放大
    # 后果: 极端场景（大文件写入）下脏页堆积略增，31G 内存下无影响
    "vm.dirty_ratio" = 20; # 脏页占总内存比例上限20%
    "vm.dirty_background_ratio" = 5; # 后台写回触发比例5%
    "vm.dirty_expire_centisecs" = 3000; # 脏页过期时间设为30秒
    "vm.dirty_writeback_centisecs" = 500; # 脏页写回间隔设为5秒

    # XFS性能优化（针对SSD/NVMe）
    "fs.xfs.inherit_nodump" = 1; # 继承nodump标志
    "fs.xfs.inherit_noatime" = 1; # 继承noatime标志（减少写入）
    "fs.xfs.inherit_nosymlinks" = 1; # 继承nosymlinks标志
    "fs.xfs.filestream_centisecs" = 3000; # 文件流分配器超时
  };
}
