#!/usr/bin/env bash
# 指纹设备（06cb:00f0 Synaptics）保持常开
# ⚠️ USB 路径会变（3-3.4 → 3-2.4 等）——动态按 idVendor 找，不硬编码
set -euo pipefail

for d in /sys/bus/usb/devices/*/; do
  if [ "$(cat "$d/idVendor" 2>/dev/null)" = "06cb" ]; then
    echo on > "$d/power/control" 2>/dev/null || true
  fi
done
