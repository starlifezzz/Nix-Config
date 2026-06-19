# /etc/nixos/modules/services/system-daemons.nix
# 系统级守护进程 (fwupd, earlyoom)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.fwupd.enable
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.earlyoom.enable
{ ... }:

{
  # 固件更新服务
  services.fwupd.enable = true;

  # EarlyOOM - 用户空间 OOM 守护进程
  # 在内存耗尽前（剩余 5%）主动杀掉占用最多的进程，避免系统死机
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 5;  # 内存低于 5% 时触发 SIGTERM
    freeSwapThreshold = 5; # Swap 低于 5% 时触发 SIGKILL
  };
}