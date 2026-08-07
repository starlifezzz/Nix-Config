# /etc/nixos/modules/services/system-daemons.nix
# 系统级守护进程 (fwupd)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.fwupd.enable
{ ... }:

{
  # 固件更新服务
  services.fwupd.enable = true;

  # 说明：OOM 守护使用 systemd-oomd（官方默认启用，systemd.oomd.enable 默认 true）
  # 已移除 earlyoom 配置，遵循官方默认，避免双 OOM 守护冲突
}