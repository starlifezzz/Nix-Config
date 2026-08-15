# /etc/nixos/home/cosmic.nix
# COSMIC 桌面用户级配置（feat/cosmic 分支，替代已删除的 kde.nix）
# 分支: feat/cosmic
# 官方文档:
#   qt.platformTheme: https://nix-community.github.io/home-manager/options.xhtml#opt-qt.platformTheme.name
#   gtk: https://nix-community.github.io/home-manager/options.xhtml#opt-gtk.enable
#   dconf: https://nix-community.github.io/home-manager/options.xhtml#opt-dconf.enable
{ pkgs, ... }:

{
  # ── Qt 应用外观（COSMIC 是 GTK 风格，Qt 应用用 gtk3 平台主题）────
  qt = {
    enable = true;
    # gtk3: Qt 通过 GTK 平台主题匹配 COSMIC 的 GTK 外观
    platformTheme.name = "gtk3";
  };

  # ── GTK 主题（与用户原有 KDE 视觉风格对齐）────────────────────
  gtk = {
    enable = true;
    # 原 KDE 分支用 BreezeLight；COSMIC 下用 GTK 亮色主题弱化
    theme.name = "Adwaita";
    iconTheme.name = "Papirus";
    font.name = "LXGW WenKai Screen";
    font.size = 10;
  };

  dconf.enable = true;
}
