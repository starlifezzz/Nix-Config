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

    # ── force 覆盖已存在的 GTK 配置文件 ─────────────────────────
    # 原因: 首次激活时磁盘上存在 KDE 时代遗留的 ~/.gtkrc-2.0、
    #       ~/.config/gtk-3.0/settings.ini、gtk-4.0/settings.ini，
    #       不声明 force 则 HM 拒绝覆盖导致 home-manager 服务失败。
    # 数据保全: 已核对旧文件内容（LXGW 字体 / Papirus 图标），
    #           与本声明式配置一致，覆盖无数据损失。
    # 官方选项: gtk2 -> https://nix-community.github.io/home-manager/options.xhtml#opt-gtk.gtk2.force
    #         gtk3/4 -> xdg.configFile 属性合并补 force（无独立官方选项），
    #                   模式同本仓库 home/default.nix 的 mimeapps.list.force
    gtk2.force = true;
  };

  # gtk3/gtk4 settings.ini 由 gtk 模块的 xdg.configFile 写入；
  # 通过属性合并为其补加 force（gtk 模块未暴露独立 force 选项）
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  # ═══════════════════════════════════════════════════════════
  # COSMIC 桌面配置声明式固化（快照 2026-08-27）
  # ═══════════════════════════════════════════════════════════
  # 机制说明:
  #   COSMIC 配置存储于 ~/.config/cosmic/<段名>/<版本>/<键>，
  #   每个<键>是一个 RON 格式的独立文件（COSMIC settings-daemon 读写）。
  #   本仓库 cosmic-config/ 目录保存 2026-08-27 从 GUI 固化的完整快照
  #   （含 Papirus 图标、LXGW 字体、面板/坞布局、主题色、快捷键等 187 个文件）。
  #
  # 为什么要用 xdg.configFile 整目录 + force:
  #   - 用户级 ~/.config/cosmic 优先级最高（NixOS Wiki: "User configuration
  #     files override the system defaults when present"），
  #     因此固化到用户级即可完全复现当前桌面状态，无需触碰系统级 share/cosmic。
  #   - force = true: 首次激活时磁盘上已存在 COSMIC 生成的运行时配置，
  #     必须强制以声明式版本覆盖，否则 home-manager 拒绝链接导致服务失败。
  #
  # 官方参考:
  #   NixOS Wiki COSMIC 章节（配置存储与优先级规则）:
  #     https://wiki.nixos.org/wiki/COSMIC
  #   Home Manager xdg.configFile:
  #     https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.configFile
  # ⚠️ 注意:
  #   固化后如需改动 COSMIC 设置，保持"改 Nix 配置 -> switch"工作流；
  #   GUI 中的修改会在下次 switch 时被覆盖（声明式优先）。
  xdg.configFile."cosmic" = {
    source = ./cosmic-config;
    recursive = true;
    force = true;
  };

  dconf.enable = true;
}
