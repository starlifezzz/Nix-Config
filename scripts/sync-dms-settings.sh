#!/usr/bin/env bash
# 同步 DMS 实际配置 → home-manager 仓库（版本控制/回滚）
# 用法: ./scripts/sync-dms-settings.sh
set -euo pipefail

SRC="$HOME/.config/DankMaterialShell/settings.json"
DST="/etc/nixos/home/dms-settings.json"

if [ ! -f "$SRC" ]; then
  echo "❌ $SRC 不存在（DMS 尚未生成配置）"
  exit 1
fi

cp "$SRC" "$DST"
echo "✅ 已同步 DMS 配置 → $DST"
echo "（$(wc -c < "$DST") 字节）"
echo ""
echo "下一步:"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#nixos"
