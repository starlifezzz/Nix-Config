# NixOS 屏幕泛黄问题排查指南

当发现屏幕异常泛黄且已关闭"夜间颜色"功能时，按以下顺序排查：

1. **检查显示器硬件设置**（最常见原因）
- 检查显示器OSD菜单中的"护眼模式"、"低蓝光"、"阅读模式"或"色温"设置。
- 确保色温设置为6500K或"标准/Normal"，关闭任何自动护眼功能。

2. **检查系统级色彩管理服务**
- 确认`colord`服务是否运行：`systemctl --user status colord`
- 若服务存在，检查是否有异常的ICC配置文件加载：`ls ~/.local/share/icc/` 或 `~/.local/share/color/icc/`
- 尝试重置色彩配置或删除异常ICC文件。

3. **检查KDE色彩校正设置**
- 在系统设置中搜索"色彩校正"或"Color Correction"，确保未启用全局滤镜。
- 检查`~/.config/kwinrc`中是否有残留的色彩相关配置。

4. **区分全局与局部问题**
- 观察是所有应用都泛黄，还是仅特定应用（如浏览器）。
- 若仅特定应用，检查该应用的深色模式/护眼扩展或内部设置。

5. **Gamma值验证**
- 使用`xrandr --verbose | grep -i gamma`确认Gamma值为1.0:1.0:1.0。
- 若异常，使用`xrandr --output <display> --gamma 1:1:1`重置。

**注意**：NixOS系统更新后，某些默认配置可能被重置或新服务被启用，需重新检查色彩管理相关服务状态。

---

## 🟡 KDE Night Color（夜间颜色）导致泛黄的专项处理

### 症状
- 屏幕整体偏黄/暖色调
- Gamma 值正常（1.0:1.0:1.0）
- 显示器硬件设置无异常
- 系统更新后突然出现

### 根本原因
KDE Plasma 的 **Night Color（夜间颜色）** 功能可能在系统更新后被意外启用，即使你从未主动开启它。

### 快速诊断

```bash
# 检查夜间颜色状态文件是否存在
ls -la ~/.local/state/knighttimestaterc

# 如果文件存在，说明夜间颜色曾被启用过
cat ~/.local/state/knighttimestaterc
```

### 立即修复

```bash
# 1. 删除夜间颜色状态文件
rm ~/.local/state/knighttimestaterc

# 2. 重新加载 KWin 配置
qdbus org.kde.KWin /KWin org.kde.KWin.reconfigure

# 3. （可选）重启 Plasma Shell
killall plasmashell && kstart5 plasmashell &
```

### 永久禁用（通过 Home Manager）

本配置已在 [`home/kde.nix`](../home/kde.nix) 中添加了自动清理机制：

```nix
home.activation.disableNightColor = lib.hm.dag.entryAfter ["writeBoundary"] ''
  $DRY_RUN_CMD rm -f $HOME/.local/state/knighttimestaterc
'';
```

每次应用 Home Manager 配置时，都会自动清理夜间颜色状态文件。

### 预防措施

1. **避免在 KDE 系统设置中启用"夜间颜色"**
   - 路径：系统设置 → 显示和监控 → 夜间颜色
   - 确保开关处于"关闭"状态

2. **定期检查配置文件**
   ```bash
   # 每月检查一次
   ls ~/.local/state/knighttimestaterc 2>/dev/null && echo "⚠️ 夜间颜色已启用！" || echo "✅ 正常"
   ```

3. **系统更新后立即检查**
   ```bash
   # 重建系统后执行
   sudo nixos-rebuild switch --flake .#nixos
   home-manager switch
   ls ~/.local/state/knighttimestaterc 2>/dev/null || echo "✅ 夜间颜色已清理"
   ```

### 故障排查流程

```
屏幕泛黄
  ↓
检查显示器 OSD
  ├─ 设置异常 → 调整显示器色温至 6500K → 问题解决
  └─ 设置正常 → 检查 knighttimestaterc
       ├─ 文件存在 → 删除文件 + 重载 KWin → 问题解决
       └─ 文件不存在 → 检查 colord 服务
            ├─ 运行中 → 检查 ICC 配置文件 → 问题解决
            └─ 未运行 → 检查 xrandr gamma
                 ├─ 异常 → 重置 gamma 为 1:1:1 → 问题解决
                 └─ 正常 → 联系硬件支持
```

### 技术细节

**Night Color 工作原理**：
- 基于地理位置和时间自动调整色温
- 日落时逐渐变暖（降低蓝光），日出时恢复
- 配置文件：`~/.local/state/knighttimestaterc`
- D-Bus 接口：`org.kde.KWin /NightColor`

**为什么会被意外启用**：
1. KDE Plasma 更新可能重置用户偏好
2. 系统设置向导可能默认启用
3. 导入旧配置时携带了启用状态

**Home Manager 清理机制**：
- 使用 `home.activation` 钩子
- 在每次 `home-manager switch` 时执行
- 确保配置可重复、声明式

---

**最后更新**: 2026-04-07  
**适用版本**: NixOS 26.05, KDE Plasma 6
