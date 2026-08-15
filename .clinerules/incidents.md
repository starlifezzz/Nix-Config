# 故障复盘档案（Incident Postmortems）

> 本文件记录本仓库配置相关的真实故障复盘，供未来 AI 快速查阅，避免重蹈覆辙。
> 规则性结论已固化在 `nios.md` 规则 18 / 19，此处为详细事件记录。

---

## 事件 1：微信 flatpak 无法输入中文（2026-08-15 定位并修复）

### 症状
- 微信 flatpak（com.tencent.WeChat 4.1.1.8，KDE Plasma 6 Wayland）无法输入中文，只能打英文，fcitx 切换无反应。
- 同配置的旧机（NixOS 26.11.20260723，未打 8月7日 之后的配置变更）**完全正常**。

### 错误排查路径（浪费 8 天，必须引以为戒）
1. ❌ 直接投入运行时取证：进程 environ（渲染器无 XMODIFIERS）、XIM 协议探测、socket 检查、fcitx5-diagnose、DBus DebugInfo。
2. ❌ 被表面现象带偏：测得 "WeChatAppEx 渲染器 8/8 无 XMODIFIERS" + flatpak 只开 x11 socket → 误判"微信渲染器无法连接任何 IME"。
3. ❌ 中途看到 kde.nix 注释（"该行导致双重启动冲突"）就采信其解释，未质疑因果是否倒置。
4. ❌ 甚至一度考虑替换为 nixpkgs 微信包、临时切 X11 会话等绕路方案。

### 真正的根因（git 铁证）
- 提交 `a4df79b`（2026-08-07）"Drop the InputMethod= line ... to stop duplicate fcitx5 startup" 删除了 kwinrc 的：

  ```
  [Wayland]
  InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop
  ```

- **机制**（官方文档确认）：
  - KDE Plasma Wayland 要求输入法进程**由 KWin 调用**（ArchWiki: "Plasma on Wayland requires the input method process to be invoked by KWin"）。
  - 该 `InputMethod=` 行正是 KWin 加载输入法托管组件（kwin/src/inputmethod.cpp）的唯一开关。
  - 微信渲染器跑在 XWayland，其 IME 状态必须经 KWin 转发给 fcitx5。删除该行 → KWin 不托管输入法 → XWayland 应用输入法失效。
  - "duplicate fcitx5 startup" 是伪问题：官方正确做法是让 KWin 托管 + **禁用 autostart desktop**，而非删除 `InputMethod=`。

- **旧机对照**：旧机（7月24日 HEAD，含该行 + autostart 共存）微信正常 → 实证"该行存在时系统正常工作"。

### 修复（已生效）
1. `/etc/nixos/home/kde.nix`：恢复 `InputMethod=/run/current-system/sw/share/applications/org.fcitx.Fcitx5.desktop`。
2. `/etc/nixos/home/fcitx5.nix`：清空 `DisabledAddons`（与旧机未托管时默认全启用对齐，保留 xim / dbusfrontend 等）。

### 教训（已固化为规则）
- **配置回归类问题：先 git diff 变更史，再动运行时工具**（规则 18）。
- **KDE Wayland 下 kwinrc `InputMethod=` 严禁删除**（规则 19）。
- 对提交说明要持怀疑态度："消除重复启动/清理冗余"这类动机描述可能因果倒置，须先验证功能通路再动手。

### 相关参考
- 官方文档：
  - https://wiki.archlinux.org/title/Fcitx5 （KDE Plasma 段落）
  - https://fcitx-im.org/wiki/Special:MyLanguage/Setup_Fcitx_5 （KWin Wayland 5.24+ 段落）
  - https://bugs.kde.org/show_bug.cgi?id=506095 （KWin XWayland IME 相关性社区证据）
- 相关 git 提交：
  - 肇事：`a4df79b`（2026-08-07 删 InputMethod=）
  - 确认引入时间点：`184cfd6`（2026-08-03 该行存在且正常）
  - 本次修复：`home/kde.nix` + `home/fcitx5.nix`（2026-08-15）