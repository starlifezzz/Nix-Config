# /etc/nixos/home/dms.nix
# DMS (DankMaterialShell) 桌面 shell 配置
# ═══ 完全由 nixpkgs 管理 ═══
#   - 包 + NixOS 模块: programs.dms-shell（见 configuration.nix）
#   - 更新: nix flake update nixpkgs（无独立 DMS flake input）
#
# ═══ 配置策略：动态配置不写死 ═══
# settings.json 由 DMS **自主管理**（不整体声明）：
#   - 动态行为（matugen 自动配色/壁纸/主题）需运行时更新——写死会冻结
#   - 固定项（bar 自动隐藏/greeter 指纹）由激活脚本"仅首次初始化"写入
#     （见 home/niri.nix 的 syncDmsSettings——文件存在则不覆盖）
{
  pkgs,
  lib,
  ...
}:
{
  # ═══ DMS 配置：DMS 自主 + HM 仓库同步 ═══
  # settings.json 由 DMS 运行时管理（真实文件可写——HM 部署软链会只读导致 DMS 设置失效）
  # home/dms-settings.json 是同步副本（版本控制/回滚）
  # 工作流: DMS 设置中心改 → ./scripts/sync-dms-settings.sh（同步到 HM）→ rebuild
  # ⚠️ 不部署 settings.json（避免 clobber + 只读冲突）
}
