#!/usr/bin/env bash
# 同步 DMS 配置 → home-manager 仓库（版本控制/回滚）
#
# 机制说明（声明式只读模式）:
#   settings.json 由 home.file 声明式部署为**只读软链**（见 home/dms.nix）。
#   DMS 设置中心改设置时无法写回文件（只读），改动仅在**运行中内存**生效。
#   本脚本通过 `dms ipc call settings dump` 导出运行中的完整配置，
#   覆盖 home/dms-settings.json，然后 rebuild 入库 —— 复制即一致。
#
# 用法: ./scripts/sync-dms-settings.sh
set -euo pipefail

DST="/etc/nixos/home/dms-settings.json"

if ! command -v dms >/dev/null 2>&1; then
  echo "❌ 找不到 dms 命令（DMS 未安装）"
  exit 1
fi

DUMP="$(dms ipc call settings dump 2>/dev/null || true)"
if [ -z "$DUMP" ] || ! printf '%s' "$DUMP" | python3 -m json.tool >/dev/null 2>&1; then
  echo "❌ 无法从运行中的 DMS 导出配置（DMS 是否在运行？）"
  echo "   请在登录会话中（DMS 已启动）运行本脚本。"
  exit 1
fi

# 美化缩进后写入仓库
printf '%s' "$DUMP" | python3 -m json.tool --no-ensure-ascii > "$DST"
echo "✅ 已从运行中的 DMS 同步配置 → $DST"
echo "（$(wc -c < "$DST") 字节）"
echo ""
echo "下一步:"
echo "  sudo nixos-rebuild switch --flake /etc/nixos#nixos"
