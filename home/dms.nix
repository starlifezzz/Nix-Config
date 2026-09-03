# /etc/nixos/home/dms.nix
# DMS (DankMaterialShell) 桌面 shell 配置
# ═══ 完全由 nixpkgs 管理 ═══
#   - 包 + NixOS 模块: programs.dms-shell（见 configuration.nix）
#   - 更新: nix flake update nixpkgs（无独立 DMS flake input）
#
# ═══ 配置策略：声明式，复制即一致 ═══
# settings.json 由 home.file **声明式部署**（只读软链指向 /nix/store 副本）：
#   - 任何机器 clone 本仓库 → nixos-rebuild → settings.json 完全一致，无需手动同步
#   - DMS 检测到只读 settings.json 时，设置中心改动会弹"只读 + 复制新值"提示
#   - 若在设置中心改了想回写：dms ipc call settings dump 导出 → 覆盖 home/dms-settings.json
#   - 动态状态（壁纸/会话）仍由 DMS 写在 ~/.local/state/DankMaterialShell/session.json，不冻结
{
  pkgs,
  lib,
  ...
}:
{
  # ═══ DMS 配置：声明式部署 settings.json ═══
  # source: 指向仓库副本（/nix/store 只读）→ 复制即一致
  # force:  旧的真实文件存在时也行，HM 会覆盖并备份
  # ⚠️ home.file 路径相对于 $HOME，DMS 读 ~/.config/DankMaterialShell/settings.json，
  #    所以必须带 .config/ 前缀（否则会误放到 ~/DankMaterialShell/）
  home.file.".config/DankMaterialShell/settings.json" = {
    source = ./dms-settings.json;
    force = true;
  };
}
