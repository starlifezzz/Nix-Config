# /etc/nixos/modules/services/system-daemons.nix
# 系统级守护进程 (fwupd)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.fwupd.enable
{ ... }:

{
  # 固件更新服务
  services.fwupd.enable = true;

  # nscd：保持默认启用。
  # 尝试关闭失败——NixOS 断言：启用 system.nssModules（avahi 的 nss-mdns，KDE Connect 的 .local 解析依赖）
  # 就要求 services.nscd.enable = true。要关须同时 system.nssModules = mkForce []（会破坏 mDNS）。

  # 说明：OOM 守护使用 systemd-oomd（官方默认启用，systemd.oomd.enable 默认 true）
  # 已移除 earlyoom 配置，遵循官方默认，避免双 OOM 守护冲突
}
