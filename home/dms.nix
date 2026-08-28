# /etc/nixos/home/dms.nix
# DMS (DankMaterialShell) 桌面 shell 配置（替代 Clavis Shell）
# 源码: github:AvengeMedia/DankMaterialShell（7.8k stars，活跃维护）
# 功能: 状态栏/启动器/控制中心/通知/剪贴板历史/锁屏/壁纸管理（原生支持 bar 自动隐藏）
#
# 集成策略:
#   - 包: nixpkgs dms-shell（稳定版，构建无忧，更新由 nixpkgs 管）
#   - 模块: GitHub flake（homeModules.dank-material-shell）
#   - settings: 不声明（空）——让 DMS 完全自主管理 settings.json，
#     避免 HM 声明覆盖 DMS 运行时修改（bar/主题/壁纸设置会重置）
#   - niri 集成: 预置 include dms/*.kdl 分片（见 niri.nix extraConfig），
#     DMS 设置中心直接写可写分片，不碰只读 config.kdl
{
  pkgs,
  lib,
  ...
}:
{
  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    # 用 nixpkgs 稳定版（1.5.3）——构建稳定 + 更新由 nixpkgs
    # （不构建 GitHub flake 的 DMS，避开 master 的 AGENTS.md symlink bug）
    package = pkgs.dms-shell;

    # 空 settings → HM 不写 settings.json → DMS 完全自主（设置永不被覆盖）
    settings = { };
  };
}
