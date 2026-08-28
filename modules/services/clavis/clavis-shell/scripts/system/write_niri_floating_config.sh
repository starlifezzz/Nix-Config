#!/usr/bin/env bash
# 平铺/浮动窗口模式切换（Clavis WindowModeService 调用）
# 用法: write_niri_floating_config.sh <true|false> <floating.kdl路径> [niri命令]
set -euo pipefail

floating="${1:?missing floating mode}"
fragment="${2:?missing fragment path}"
niri_command="${3:-niri}"

mkdir -p "$(dirname -- "$fragment")"

if [ "$floating" = "true" ]; then
    cat > "$fragment" << 'FRAG'
// Window mode: floating (managed by Clavis WindowModeService)
window-rule {
    match app-id=r#"^.*$"#
    open-floating true
}
FRAG
else
    rm -f -- "$fragment"
fi

# 重载 niri 配置应用新窗口模式（失败不影响运行，niri 保留旧配置）
"$niri_command" msg action load-config-file >/dev/null 2>&1 || true
echo "ready"
