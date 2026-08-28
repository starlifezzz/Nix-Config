#!/usr/bin/env bash
# niri-auto-output: 自动检测显示器，生成最优 output.kdl
# 原理: 解析 niri msg outputs 的所有 mode
#   - 选最高分辨率（面积最大 width*height）
#   - 该分辨率下选最高刷新率
# 换显示器/4K → 重跑本脚本 → niri msg action load-config-file 生效
# 零写死：分辨率/刷新率全自动
set -euo pipefail

OUTPUT_KDL="${XDG_CONFIG_HOME:-$HOME/.config}/niri/output.kdl"
OUTPUTS="$(niri msg outputs 2>/dev/null || true)"

if [ -z "$OUTPUTS" ]; then
  exit 0
fi

GENERATED="$(python3 - "$OUTPUTS" << 'EOF'
import sys, re
text = sys.argv[1]
blocks = re.split(r'\n(?=Output ")', text)
result = []
for block in blocks:
    m = re.search(r'Output "([^"]+)"', block)
    if not m:
        continue
    name = m.group(1)
    modes = re.findall(r'^\s+(\d+)x(\d+)@([\d.]+)', block, re.M)
    if not modes:
        continue
    # 最高分辨率（面积最大），同分辨率取最高刷新率
    best = max(modes, key=lambda t: (int(t[0]) * int(t[1]), float(t[2])))
    result.append(f'output "{name}" {{')
    result.append(f'    mode "{best[0]}x{best[1]}@{best[2]}"')
    result.append('    variable-refresh-rate')
    result.append('}')
    result.append('')
print('\n'.join(result))
EOF
)"

mkdir -p "$(dirname "$OUTPUT_KDL")"
echo "$GENERATED" > "$OUTPUT_KDL"

# 重载 niri 配置应用新 output
niri msg action load-config-file 2>/dev/null || true
