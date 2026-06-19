# /etc/nixos/modules/services/sandbox.nix
# 沙盒与容器服务 (Flatpak)
# 官方文档：
#   https://nixos.org/manual/nixos/unstable/options.html#opt-services.flatpak.enable
{ ... }:

{
  # Flatpak - 桌面应用沙盒
  services.flatpak.enable = true;
}