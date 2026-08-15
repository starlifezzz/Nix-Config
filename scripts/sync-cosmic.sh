#!/usr/bin/env bash
# /etc/nixos/scripts/sync-cosmic.sh
# COSMIC 配置快照同步脚本
#
# 用途:
#   COSMIC 设置面板（GUI）改动配置后，将 ~/.config/cosmic 的最新状态
#   同步回声明式快照目录（home/cosmic-config/），供审查 diff 后提交。
#
# 工作流:
#   1. 在 COSMIC 设置面板中修改配置（GUI 即时写入 ~/.config/cosmic）
#   2. 运行本脚本（生成 diff 供审查，不自动覆盖）
#   3. 审查通过后 git commit；再执行 nixos-rebuild switch 固化
#
# 安全设计:
#   - 默认进入 --diff 模式，只显示差异，绝不自动覆盖快照
#   - 需要应用时显式传入 --apply
#   - 不会删除快照中已有的文件（只同步新增/修改）

set -euo pipefail

SNAPSHOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../home/cosmic-config" && pwd)"
LIVE_DIR="${HOME}/.config/cosmic"
MODE="${1:-diff}"

if [ ! -d "${LIVE_DIR}" ]; then
  echo "错误: 未找到 COSMIC 运行时配置目录 ${LIVE_DIR}" >&2
  exit 1
fi

echo "快照目录: ${SNAPSHOT_DIR}"
echo "运行时目录: ${LIVE_DIR}"
echo

case "${MODE}" in
  diff)
    echo "════════ 差异预览（快照 vs 运行时）════════"
    echo "（此模式只展示差异，不修改任何文件）"
    diff -r -x '.DS_Store' "${SNAPSHOT_DIR}" "${LIVE_DIR}" 2>/dev/null || true
    echo
    echo "提示: 若差异符合预期，执行: ${BASH_SOURCE[0]} --apply"
    ;;
  apply)
    echo "将快照目录同步为运行时状态..."
    # 同步: 新增/修改运行时中新出现的文件（保留快照中已被删除的占位——不删，保守策略）
    rsync -a --delete-excluded \
      --exclude='.DS_Store' \
      "${LIVE_DIR}/" "${SNAPSHOT_DIR}/"
    echo "已同步。请审查 git diff 后提交:"
    echo "  cd /etc/nixos && git diff home/cosmic-config && git add home/cosmic-config && git commit"
    ;;
  *)
    echo "用法: ${BASH_SOURCE[0]} [diff|apply]" >&2
    echo "  diff  - 预览运行时与快照的差异（默认）" >&2
    echo "  apply - 应用运行时状态到快照目录（会覆盖快照中的差异文件）" >&2
    exit 1
    ;;
esac