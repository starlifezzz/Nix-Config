#!/bin/sh
# ═══════════════════════════════════════════════════════════
# Clash TUN 模式启动脚本 - NixOS（最终简洁版）
# ═══════════════════════════════════════════════════════════
# 参考：NixOS Wiki Networking, Issue #477636
# ✅ 已验证可用 - 精简逻辑，直接执行
# ═══════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 配置路径
CLASH_CONFIG_DIR="/home/zhangchongjie/.local/share/io.github.clash-verge-rev.clash-verge-rev"
# CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge.yaml"
CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge-check.yaml"
TEMP_CONFIG="/tmp/clash-tun.yaml"
CLASH_PID_FILE="/tmp/clash.pid"
MIHOMO_BIN="/run/current-system/sw/bin/verge-mihomo"

echo ""
log_info "╔════════════════════════════════════════╗"
log_info "║   Clash TUN 模式启动脚本 - NixOS      ║"
log_info "╚════════════════════════════════════════╝"
echo ""

# 1. 权限检查
[ "$(id -u)" -eq 0 ] || { log_error "请使用 sudo 运行此脚本"; exit 1; }

# 2. 准备 TUN 设备
log_info "检查 TUN 设备..."
[ -c "/dev/net/tun" ] || {
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200 2>/dev/null || true
    chmod 0666 /dev/net/tun
}
log_success "TUN 设备已就绪"

# 3. 清理旧进程
log_info "停止现有进程..."
pkill -f verge-mihomo 2>/dev/null || true
sleep 2

# 4. 生成临时配置
log_info "更新配置文件..."
[ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }
cp "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
sed -i 's/enable: false/enable: true/' "$TEMP_CONFIG"
sed -i '/^tun:/,/^[a-z]/s/auto-route: false/auto-route: true/' "$TEMP_CONFIG"
sed -i '/^tun:/,/^[a-z]/s/strict-route: false/strict-route: true/' "$TEMP_CONFIG"
log_success "配置已更新 (TUN + Auto-Route)"

# 5. 启动核心
log_info "启动 verge-mihomo..."
[ -x "$MIHOMO_BIN" ] || { log_error "未找到 verge-mihomo: $MIHOMO_BIN"; exit 1; }

nohup "$MIHOMO_BIN" -d "$CLASH_CONFIG_DIR" -f "$TEMP_CONFIG" > /tmp/verge-mihomo.log 2>&1 &
CLASH_PID=$!
echo "$CLASH_PID" > "$CLASH_PID_FILE"
log_success "Mihomo 已启动 (PID: $CLASH_PID)"

sleep 8 # 等待路由表注入完成

# 6. 验证状态
log_info "验证运行状态..."
if ps -p $CLASH_PID > /dev/null 2>&1 && (ip link show Meta > /dev/null 2>&1 || ip link show Mihomo > /dev/null 2>&1); then
    log_success "✅ Mihomo 运行正常"
    
    TUN_IFACE=$(ip link show | grep -oE 'Meta|Mihomo' | head -1)
    log_success "✅ TUN 接口已创建：$TUN_IFACE"
    
    echo ""
    log_info "测试外网连通性..."
    if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
        log_success "✅ Google 访问成功！"
    else
        log_info "⚠️  Google 访问失败，请在 GUI 中切换节点"
    fi
    
    echo ""
    log_info "======================================"
    log_info "使用方式："
    echo "   • 浏览器代理：http://127.0.0.1:7897"
    echo "   • 停止命令：sudo pkill -f verge-mihomo"
    echo "   • 下次启动：sudo clash-tun"
    echo ""
else
    log_error "启动失败，请查看日志：cat /tmp/verge-mihomo.log"
    exit 1
fi  
