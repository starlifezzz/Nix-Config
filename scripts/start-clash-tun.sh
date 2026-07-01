# #!/bin/sh
# # ═══════════════════════════════════════════════════════════
# # Clash TUN 模式启动脚本 - NixOS（最终简洁版）
# # ═══════════════════════════════════════════════════════════
# # 参考：NixOS Wiki Networking, Issue #477636
# # ✅ 已验证可用 - 精简逻辑，直接执行
# # ═══════════════════════════════════════════════════════════

# set -e

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# BLUE='\033[0;34m'
# NC='\033[0m'

# log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
# log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
# log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# # 配置路径
# CLASH_CONFIG_DIR="/home/zhangchongjie/.local/share/io.github.clash-verge-rev.clash-verge-rev"
# # CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge.yaml"
# CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge-check.yaml"
# TEMP_CONFIG="/tmp/clash-tun.yaml"
# CLASH_PID_FILE="/tmp/clash.pid"
# # MIHOMO_BIN="/run/current-system/sw/bin/verge-mihomo"
# MIHOMO_BIN="/etc/profiles/per-user/zhangchongjie/bin/verge-mihomo"


# echo ""
# log_info "╔════════════════════════════════════════╗"
# log_info "║   Clash TUN 模式启动脚本 - NixOS      ║"
# log_info "╚════════════════════════════════════════╝"
# echo ""

# # 1. 权限检查
# [ "$(id -u)" -eq 0 ] || { log_error "请使用 sudo 运行此脚本"; exit 1; }

# # 2. 准备 TUN 设备
# log_info "检查 TUN 设备..."
# [ -c "/dev/net/tun" ] || {
#     mkdir -p /dev/net
#     mknod /dev/net/tun c 10 200 2>/dev/null || true
#     chmod 0666 /dev/net/tun
# }
# log_success "TUN 设备已就绪"

# # 3. 清理旧进程
# log_info "停止现有进程..."
# pkill -f verge-mihomo 2>/dev/null || true
# sleep 2
# # 强制 NetworkManager 重新加载物理网卡的路由和 DNS，模拟 KDE 的自动恢复机制
# nmcli networking off && sleep 1 && nmcli networking on
# # 重启 DNS 解析服务，清除假 IP 劫持
# systemctl restart systemd-resolved
# sleep 2

# # 4. 生成临时配置
# log_info "更新配置文件..."
# [ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }
# cp "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
# sed -i 's/enable: false/enable: true/' "$TEMP_CONFIG"
# sed -i '/^tun:/,/^[a-z]/s/auto-route: false/auto-route: true/' "$TEMP_CONFIG"
# sed -i '/^tun:/,/^[a-z]/s/strict-route: false/strict-route: true/' "$TEMP_CONFIG"
# log_success "配置已更新 (TUN + Auto-Route)"

# # 5. 启动核心
# log_info "启动 verge-mihomo..."
# [ -x "$MIHOMO_BIN" ] || { log_error "未找到 verge-mihomo: $MIHOMO_BIN"; exit 1; }

# nohup "$MIHOMO_BIN" -d "$CLASH_CONFIG_DIR" -f "$TEMP_CONFIG" > /tmp/verge-mihomo.log 2>&1 &
# CLASH_PID=$!
# echo "$CLASH_PID" > "$CLASH_PID_FILE"
# log_success "Mihomo 已启动 (PID: $CLASH_PID)"

# sleep 8 # 等待路由表注入完成

# # 6. 验证状态
# log_info "验证运行状态..."
# if ps -p $CLASH_PID > /dev/null 2>&1 && (ip link show Meta > /dev/null 2>&1 || ip link show Mihomo > /dev/null 2>&1); then
#     log_success "✅ Mihomo 运行正常"
    
#     TUN_IFACE=$(ip link show | grep -oE 'Meta|Mihomo' | head -1)
#     log_success "✅ TUN 接口已创建：$TUN_IFACE"
    
#     echo ""
#     log_info "测试外网连通性..."
#     if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
#         log_success "✅ Google 访问成功！"
#     else
#         log_info "⚠️  Google 访问失败，请在 GUI 中切换节点"
#     fi
    
#     echo ""
#     log_info "======================================"
#     log_info "使用方式："
#     echo "   • 浏览器代理：http://127.0.0.1:7897"
#     echo "   • 停止命令：sudo pkill -f verge-mihomo"
#     echo "   • 下次启动：sudo clash-tun"
#     echo ""
# else
#     log_error "启动失败，请查看日志：cat /tmp/verge-mihomo.log"
#     exit 1
# fi  


# #!/bin/sh
# # ═══════════════════════════════════════════════════════════
# # Clash TUN 模式启动脚本 - NixOS（Clash Meta 内核版）
# # ═══════════════════════════════════════════════════════════
# # 参考：NixOS Wiki Networking, Issue #477636
# # ✅ 已验证可用 - 精简逻辑，直接执行
# # ═══════════════════════════════════════════════════════════

# set -e

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# BLUE='\033[0;34m'
# NC='\033[0m'

# log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
# log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
# log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# # 配置路径
# CLASH_CONFIG_DIR="/home/zhangchongjie/.local/share/io.github.clash-verge-rev.clash-verge-rev"
# # CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge.yaml"
# CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge-check.yaml"
# TEMP_CONFIG="/tmp/clash-tun.yaml"
# CLASH_PID_FILE="/tmp/clash.pid"

# # 🔄 核心修改：使用 clash-meta 内核
# CLASH_META_BIN="/etc/profiles/per-user/zhangchongjie/bin/clash-meta"

# echo ""
# log_info "╔════════════════════════════════════════╗"
# log_info "║  Clash TUN 启动脚本 (Clash Meta 内核)  ║"
# log_info "╚════════════════════════════════════════╝"
# echo ""

# # 1. 权限检查
# [ "$(id -u)" -eq 0 ] || { log_error "请使用 sudo 运行此脚本"; exit 1; }

# # 2. 准备 TUN 设备
# log_info "检查 TUN 设备..."
# [ -c "/dev/net/tun" ] || {
#     mkdir -p /dev/net
#     mknod /dev/net/tun c 10 200 2>/dev/null || true
#     chmod 0666 /dev/net/tun
# }
# log_success "TUN 设备已就绪"

# # 3. 清理旧进程
# log_info "停止现有进程..."
# # 🔄 核心修改：精准查杀 clash-meta
# pkill -f clash-meta 2>/dev/null || true
# sleep 2
# # 强制 NetworkManager 重新加载物理网卡的路由和 DNS，模拟 KDE 的自动恢复机制
# nmcli networking off && sleep 1 && nmcli networking on
# # 重启 DNS 解析服务，清除假 IP 劫持
# systemctl restart systemd-resolved
# sleep 2

# # 4. 生成临时配置
# log_info "更新配置文件..."
# [ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }
# cp "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
# sed -i 's/enable: false/enable: true/' "$TEMP_CONFIG"
# sed -i '/^tun:/,/^[a-z]/s/auto-route: false/auto-route: true/' "$TEMP_CONFIG"
# sed -i '/^tun:/,/^[a-z]/s/strict-route: false/strict-route: true/' "$TEMP_CONFIG"
# log_success "配置已更新 (TUN + Auto-Route)"

# # 5. 启动核心
# log_info "启动 clash-meta..."
# [ -x "$CLASH_META_BIN" ] || { log_error "未找到 clash-meta: $CLASH_META_BIN"; exit 1; }

# # 🔄 核心修改：日志输出到 clash-meta.log
# nohup "$CLASH_META_BIN" -d "$CLASH_CONFIG_DIR" -f "$TEMP_CONFIG" > /tmp/clash-meta.log 2>&1 &
# CLASH_PID=$!
# echo "$CLASH_PID" > "$CLASH_PID_FILE"
# log_success "Clash Meta 已启动 (PID: $CLASH_PID)"

# sleep 8 # 等待路由表注入完成

# # 6. 验证状态
# log_info "验证运行状态..."
# # 注：clash-meta (mihomo) 创建的 TUN 接口名通常为 Meta 或 Mihomo
# if ps -p $CLASH_PID > /dev/null 2>&1 && (ip link show Meta > /dev/null 2>&1 || ip link show Mihomo > /dev/null 2>&1); then
#     log_success "✅ Clash Meta 运行正常"
    
#     TUN_IFACE=$(ip link show | grep -oE 'Meta|Mihomo' | head -1)
#     log_success "✅ TUN 接口已创建：$TUN_IFACE"
    
#     echo ""
#     log_info "测试外网连通性..."
#     if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
#         log_success "✅ Google 访问成功！"
#     else
#         log_info "⚠️  Google 访问失败，请在 GUI 中切换节点"
#     fi
    
#     echo ""
#     log_info "======================================"
#     log_info "使用方式："
#     echo "   • 浏览器代理：http://127.0.0.1:7897"
#     # 🔄 核心修改：停止命令更新
#     echo "   • 停止命令：sudo pkill -f clash-meta"
#     echo "   • 下次启动：sudo clash-tun"
#     echo ""
# else
#     # 🔄 核心修改：日志路径更新
#     log_error "启动失败，请查看日志：cat /tmp/clash-meta.log"
#     exit 1
# fi  


#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Clash TUN 模式启动脚本 - NixOS（满血复活版）
# 融合了最初版本的稳定路由逻辑 + 自动更新订阅/规则功能
# ═══════════════════════════════════════════════════════════

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[0;33m'; NC='\033[0m'
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ═══════════════════════════════════════════════════════════
# 配置路径
# ═══════════════════════════════════════════════════════════
CLASH_CONFIG_DIR="/home/zhangchongjie/.local/share/io.github.clash-verge-rev.clash-verge-rev"
CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge-check.yaml"
TEMP_CONFIG="/tmp/clash-tun.yaml"
CLASH_PID_FILE="/tmp/clash.pid"
CLASH_META_BIN="/etc/profiles/per-user/zhangchongjie/bin/clash-meta"

# 订阅与规则配置
SUB_URL="https://103.14.76.98/sub/fsc/73623668d01a5f26dd678989b2ae9cec"
SUB_UA="clash-verge/v2.4.5"
GEOSITE_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
GEOIP_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"

FORCE_UPDATE=false

# ═══════════════════════════════════════════════════════════
# 🏭 配置加工厂：清理冲突 + 注入 NixOS 专属高性能配置
# ═══════════════════════════════════════════════════════════
process_config() {
    local SOURCE_FILE="$1"
    local TARGET_FILE="$2"
    
    cp "$SOURCE_FILE" "$TARGET_FILE"
    
    # 1. 删除单行冲突 Key
    sed -i '/^log-level:/d' "$TARGET_FILE"
    sed -i '/^external-controller:/d' "$TARGET_FILE"
    sed -i '/^secret:/d' "$TARGET_FILE"
    sed -i '/^external-ui:/d' "$TARGET_FILE"
    sed -i '/^external-ui-url:/d' "$TARGET_FILE"
    sed -i '/^external-ui-name:/d' "$TARGET_FILE"
    sed -i '/^fallback:/d' "$TARGET_FILE"
    sed -i '/^fallback-filter:/d' "$TARGET_FILE"

    # 2. 删除多行冲突块 (dns, tun, sniffer, profile)
    sed -i '/^dns:/,/^[a-zA-Z]/ { /^dns:/d; /^[a-zA-Z]/!d; }' "$TARGET_FILE"
    sed -i '/^tun:/,/^[a-zA-Z]/ { /^tun:/d; /^[a-zA-Z]/!d; }' "$TARGET_FILE"
    sed -i '/^sniffer:/,/^[a-zA-Z]/ { /^sniffer:/d; /^[a-zA-Z]/!d; }' "$TARGET_FILE"
    sed -i '/^profile:/,/^[a-zA-Z]/ { /^profile:/d; /^[a-zA-Z]/!d; }' "$TARGET_FILE"



    # 3. 注入我们的完美配置
    cat << 'EOF' >> "$TARGET_FILE"

# --- 🎛️ API 与 Web UI 面板配置 ---
external-controller: 127.0.0.1:9090
external-ui: ui
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# --- 🚀 脚本自动注入：NixOS 专属高性能配置 ---
log-level: error               # 🔇 绝对安静，只记录致命错误
tcp-concurrent: true
unified-delay: true
find-process-mode: off

profile:
  store-selected: true
  store-fake-ip: true

sniffer:
  enable: true
  sniff:
    HTTP: { ports: [80, 8080-8880], override-destination: true }
    TLS:  { ports: [443, 8443] }
    QUIC: { ports: [443, 8443] }
  skip-domain:
    - "Mijia Cloud"
    - "+.push.apple.com"

dns:
  enable: true
  ipv6: false
  prefer-h3: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:
    - '*.lan'
    - '*.local'
    - 'localhost.ptlogin2.qq.com'
    - '+.stun.*.*'
    - '+.stun.*.*.*'
    - '+.dnscloudcloud.top'
    - 'detectportal.firefox.com'
    - '+.push.apple.com'
  default-nameserver: [223.5.5.5, 119.29.29.29]
  proxy-server-nameserver: [223.5.5.5, 119.29.29.29]
  respect-rules: true
  nameserver:
    - "https://doh.pub/dns-query"
    - "https://dns.alidns.com/dns-query"
  nameserver-policy:
    "geosite:cn,private":
      - "https://doh.pub/dns-query"
      - "https://dns.alidns.com/dns-query"
    "geosite:geolocation-!cn":
      - "https://1.1.1.1/dns-query"
      - "https://8.8.8.8/dns-query"

tun:
  enable: true
  stack: system
  auto-route: true
  auto-detect-interface: true  # 🌟 官方推荐：自动检测默认出站网卡，告别硬编码
  strict-route: false
  dns-hijack:
    - any:53
EOF
}

[ "$1" = "--update" ] && FORCE_UPDATE=true

# 🆕 定时更新配置 (单位：秒，默认 24 小时)！！！！！！！！！！！！！！！！！！！！！！1
# UPDATE_INTERVAL=86400 
UPDATE_INTERVAL=1500 

echo ""
log_info "╔════════════════════════════════════════╗"
log_info "║  Clash TUN 启动脚本 (Clash Meta 内核)  ║"
log_info "╚════════════════════════════════════════╝"
echo ""

[ "$(id -u)" -eq 0 ] || { log_error "请使用 sudo 运行此脚本"; exit 1; }

# ═══════════════════════════════════════════════════════════
# 1. 更新订阅 (新增)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 1/6：更新订阅 ══════"
if [ -n "$SUB_URL" ]; then
    HTTP_CODE=$(curl -s -o "$CLASH_CONFIG_FILE.tmp" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 -L "$SUB_URL")
    if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.tmp" ]; then
        mv "$CLASH_CONFIG_FILE.tmp" "$CLASH_CONFIG_FILE"
        log_success "✅ 订阅下载成功 (HTTP $HTTP_CODE)"
    else
        log_warn "⚠️ 订阅下载失败，使用本地旧配置"
        rm -f "$CLASH_CONFIG_FILE.tmp"
    fi
else
    log_warn "未配置订阅 URL，跳过"
fi
echo ""

# ═══════════════════════════════════════════════════════════
# 2. 准备规则集 (新增)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 2/6：准备规则集 ══════"
[ "$FORCE_UPDATE" = true ] && rm -f "$CLASH_CONFIG_DIR/geosite.dat" "$CLASH_CONFIG_DIR/geoip.dat"

if [ ! -f "$CLASH_CONFIG_DIR/geosite.dat" ]; then
    log_info "下载 geosite.dat..."
    curl -s -L --retry 3 -o "$CLASH_CONFIG_DIR/geosite.dat" "$GEOSITE_URL" && log_success "✅ geosite.dat 完成"
else log_info "geosite.dat 已存在"; fi

if [ ! -f "$CLASH_CONFIG_DIR/geoip.dat" ]; then
    log_info "下载 geoip.dat..."
    curl -s -L --retry 3 -o "$CLASH_CONFIG_DIR/geoip.dat" "$GEOIP_URL" && log_success "✅ geoip.dat 完成"
else log_info "geoip.dat 已存在"; fi
echo ""

# ═══════════════════════════════════════════════════════════
# 3. 检查 TUN 设备 (最初版本逻辑)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 3/6：检查 TUN 设备 ══════"
[ -c "/dev/net/tun" ] || {
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200 2>/dev/null || true
    chmod 0666 /dev/net/tun
}
log_success "TUN 设备已就绪"
echo ""

# 4. 停止现有进程并清理残留路由 (优化版)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 4/6：停止进程与清理残留 ══════"
pkill -f clash-meta 2>/dev/null || true
sleep 2

# 🌟 优化：不再重启整个 NetworkManager，只清理可能残留的 TUN 设备
ip link delete Meta 2>/dev/null || true
ip link delete Mihomo 2>/dev/null || true

# 刷新路由缓存
sysctl -w net.ipv4.conf.all.route_localnet=1 >/dev/null 2>&1 || true

log_success "旧进程已清理，TUN 残留已回收"
echo ""


# ═══════════════════════════════════════════════════════════
# 5. 生成 TUN 配置 (调用配置加工厂)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 5/6：生成 TUN 配置与性能优化 ══════"
[ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }

log_info "清理冲突并注入 NixOS 专属配置..."
process_config "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
log_success "配置已更新 (注入 TUN + Sniffer + DoH + Web UI + NixOS网卡修复)"
echo ""


# ═══════════════════════════════════════════════════════════
# 🌟 后台守护函数：定时更新订阅 + API 热重载
# ═══════════════════════════════════════════════════════════
auto_update_daemon() {
    sleep 60 
    while true; do
        sleep "$UPDATE_INTERVAL"
        
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] 触发定时更新..." >> /tmp/clash-meta.log
        
        # 1. 下载新订阅到临时文件
        HTTP_CODE=$(curl -s -o "$CLASH_CONFIG_FILE.new" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 -L "$SUB_URL")
        
        if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.new" ]; then
            # 2. 替换基础订阅文件
            mv "$CLASH_CONFIG_FILE.new" "$CLASH_CONFIG_FILE"
            
            # 3. 🌟 核心修复：重新加工配置 (把 error 级别和 TUN 重新注入进去！)
            process_config "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
            
            # 4. 调用 API 热重载加工后的 $TEMP_CONFIG
            RELOAD_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
                -H "Content-Type: application/json" \
                -d "{\"path\": \"$TEMP_CONFIG\"}" \
                http://127.0.0.1:9090/configs)
            # 🌟 强制 patch 开启 Sniffer（防止热重载后状态丢失）
            curl -s -o /dev/null -X PATCH \
                -H "Content-Type: application/json" \
                -d '{"sniffer":{"enable":true}}' \
                http://127.0.0.1:9090/configs
                
            if [ "$RELOAD_CODE" -eq 204 ] || [ "$RELOAD_CODE" -eq 200 ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ✅ 订阅更新并热重载成功！(已重新注入 error 级别与 TUN)" >> /tmp/clash-meta.log
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ⚠️ API 热重载失败 (HTTP $RELOAD_CODE)，下次启动生效" >> /tmp/clash-meta.log
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ❌ 订阅下载失败 (HTTP $HTTP_CODE)" >> /tmp/clash-meta.log
            rm -f "$CLASH_CONFIG_FILE.new"
        fi
    done
}

# ═══════════════════════════════════════════════════════════
# 6. 启动核心与验证 (最初版本逻辑)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 6/6：启动 clash-meta ══════"
[ -x "$CLASH_META_BIN" ] || { log_error "未找到 clash-meta: $CLASH_META_BIN"; exit 1; }

nohup "$CLASH_META_BIN" -d "$CLASH_CONFIG_DIR" -f "$TEMP_CONFIG" > /tmp/clash-meta.log 2>&1 &
CLASH_PID=$!
echo "$CLASH_PID" > "$CLASH_PID_FILE"
log_success "Clash Meta 已启动 (PID: $CLASH_PID)"

sleep 8 # 等待路由表注入完成

log_info "验证运行状态..."
if ps -p $CLASH_PID > /dev/null 2>&1 && (ip link show Meta > /dev/null 2>&1 || ip link show Mihomo > /dev/null 2>&1); then
    log_success "✅ Clash Meta 运行正常"
    
    TUN_IFACE=$(ip link show | grep -oE 'Meta|Mihomo' | head -1)
    log_success "✅ TUN 接口已创建：$TUN_IFACE"
    
    echo ""
    log_info "测试外网连通性 (全局 TUN 测试)..."
    # ⚠️ 注意：这里绝对不加 -x，测试的是系统全局网络！
    if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
        log_success "✅ Google 访问成功！TUN 全局接管完美！"
    else
        log_warn "⚠️ Google 访问失败，请在 GUI/WebUI 中切换可用节点"
    fi
    
    echo ""
    log_info "======================================"
    # 🚀 启动后台定时更新守护进程
    log_info "启动后台定时更新守护进程 (间隔: $((UPDATE_INTERVAL / 3600)) 小时)..."
    auto_update_daemon &
    disown # 让守护进程脱离终端，防止关闭终端时被杀掉
    
    log_info "======================================"
    log_info "🎉 启动完成！"
    echo "   • 浏览器代理：http://127.0.0.1:7897"
    echo "   • Web UI 面板：http://127.0.0.1:9090/ui"
    echo "   • 停止命令：sudo pkill -f clash-meta"
    echo "   • 强制更新：sudo start-clash --update"
    log_info "======================================"
else
    log_error "❌ 启动失败或 TUN 网卡未创建，请查看日志：cat /tmp/clash-meta.log"
    exit 1
fi