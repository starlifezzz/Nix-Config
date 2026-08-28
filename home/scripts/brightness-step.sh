#!/usr/bin/env bash
# DDC 显示器亮度步进（外接显示器——DMS 控制中心不含 DDC，用命令行）
# 用法: brightness-step.sh <up|down> [设备]
set -euo pipefail

ACTION="${1:-up}"
DEV="${2:-ddc:i2c-6}"
STEP=5

CUR=$(dms brightness get --ddc "$DEV" 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%')
CUR=${CUR:-75}

if [ "$ACTION" = "up" ]; then
  NEW=$((CUR + STEP))
else
  NEW=$((CUR - STEP))
fi
NEW=$((NEW > 100 ? 100 : NEW))
NEW=$((NEW < 5 ? 5 : NEW))

dms brightness set --ddc "$DEV" "$NEW" >/dev/null 2>&1 || true
echo "brightness: $NEW%"
