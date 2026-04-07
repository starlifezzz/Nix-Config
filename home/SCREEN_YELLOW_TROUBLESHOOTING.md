### 永久禁用（通过 Home Manager 声明式配置）✅ **推荐**

本配置已在 [`home/kde.nix`](../home/kde.nix) 中添加了**声明式配置**：

```nix
home.file.".local/state/knighttimestaterc" = {
  text = ''
    [AutomaticLocation]
    Available=false
  '';
  force = true;
};
```

**优势**：
- ✅ **声明式管理**：通过 NixOS 符号链接直接管理配置文件
- ✅ **自动覆盖**：即使 KDE 尝试修改该文件，下次重建时会被强制覆盖
- ✅ **无需清理脚本**：不需要 activation 钩子或手动删除
- ✅ **符合 NixOS 理念**：配置即代码，状态可重现

每次执行 `sudo nixos-rebuild switch` 时，配置文件都会被自动同步。