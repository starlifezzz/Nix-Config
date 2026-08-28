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
  # ═══ DMS 配置声明式管理 ═══
  # settings.json 完整声明（home/dms-settings.json，530 字段）
  #   - bar 状态栏配置（widgets/autoHide/位置）由 HM 接管
  #   - greeter 指纹等固定项
  # 注: 动态配色在独立文件 dms-colors.json（matugen 生成）——不受此声明影响
  # 修改方法: 改 home/dms-settings.json → rebuild
  home.file.".config/DankMaterialShell/settings.json".source =
    ./dms-settings.json;
}
