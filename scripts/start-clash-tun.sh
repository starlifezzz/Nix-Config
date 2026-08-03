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
# Clash TUN 模式启动脚本 - NixOS
set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[0;33m'; NC='\033[0m'
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 配置路径
CLASH_CONFIG_DIR="$HOME/.local/share/io.github.clash-verge-rev.clash-verge-rev"
CLASH_CONFIG_FILE="$CLASH_CONFIG_DIR/clash-verge-check.yaml"
TEMP_CONFIG="/tmp/clash-tun.yaml"
CLASH_PID_FILE="/tmp/clash.pid"
CLASH_META_BIN="/etc/profiles/per-user/zhangchongjie/bin/mihomo"
WEBUI_DIR="$CLASH_CONFIG_DIR/ui"
WEBUI_SHA_FILE="$CLASH_CONFIG_DIR/.webui-sha"
WEBUI_API_URL="https://api.github.com/repos/MetaCubeX/metacubexd/branches/gh-pages"
WEBUI_DOWNLOAD_URL="https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

SUB_URL="https://103.14.76.98/sub/fsc/73623668d01a5f26dd678989b2ae9cec"
SUB_UA="clash-verge/v2.4.5"
GEOSITE_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
GEOIP_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"
FORCE_UPDATE=false

# 配置加工厂
process_config() {
    local SOURCE_FILE="$1"
    local TARGET_FILE="$2"
    awk '
    /^(log-level|external-controller|secret|external-ui|external-ui-url|external-ui-name|fallback|fallback-filter):/ { next }
    /^(dns|tun|sniffer|profile):/ { skip=1; next }
    /^[a-zA-Z0-9_-]+:/ { skip=0 }
    !skip { print }
    ' "$SOURCE_FILE" > "$TARGET_FILE"
    cat << 'EOF' >> "$TARGET_FILE"

external-controller: 127.0.0.1:9090
external-ui: ui

log-level: error
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
  auto-detect-interface: true
  strict-route: false
  dns-hijack:
    - any:53
EOF
}

# WebUI 更新
check_update_webui() {
    set +e
    log_info "检查 WebUI (metacubexd) 是否有更新..."
    local API_RESPONSE
    API_RESPONSE=$(curl -s -H "Accept: application/vnd.github+json" \
        --connect-timeout 10 --max-time 15 "$WEBUI_API_URL" 2>/dev/null)
    if [ -z "$API_RESPONSE" ]; then
        log_warn "⚠️ 无法连接 GitHub API，跳过 WebUI 更新检查"
        return 1
    fi
    local REMOTE_SHA
    REMOTE_SHA=$(echo "$API_RESPONSE" | grep -oE '"sha"\s*:\s*"[^"]*"' | grep -oE '[a-f0-9]{7,40}' | head -1)
    if [ -z "$REMOTE_SHA" ]; then
        log_warn "⚠️ 无法解析远程版本信息，跳过 WebUI 更新检查"
        return 1
    fi
    local LOCAL_SHA=""
    [ -f "$WEBUI_SHA_FILE" ] && LOCAL_SHA=$(cat "$WEBUI_SHA_FILE")
    if [ "$REMOTE_SHA" = "$LOCAL_SHA" ] && [ -d "$WEBUI_DIR" ]; then
        log_info "WebUI 已是最新版本 (SHA: ${REMOTE_SHA:0:8})，跳过更新 ✅"
        return 0
    fi
    log_info "WebUI 需要更新：${LOCAL_SHA:0:8} → ${REMOTE_SHA:0:8}"
    log_info "下载 metacubexd..."
    local TEMP_ZIP="/tmp/metacubexd-webui.zip"
    local TEMP_EXTRACT="/tmp/metacubexd-extract"
    local HTTP_CODE
    HTTP_CODE=$(curl -s -L --retry 3 --connect-timeout 10 --max-time 120 -o "$TEMP_ZIP" -w "%{http_code}" "$WEBUI_DOWNLOAD_URL" 2>/dev/null)
    if [ "$HTTP_CODE" != "200" ] || [ ! -s "$TEMP_ZIP" ]; then
        log_warn "⚠️ WebUI 下载失败 (HTTP $HTTP_CODE)，保留旧版本"
        rm -f "$TEMP_ZIP"
        return 1
    fi
    rm -rf "$WEBUI_DIR" "$TEMP_EXTRACT"
    mkdir -p "$TEMP_EXTRACT"
    unzip -q "$TEMP_ZIP" -d "$TEMP_EXTRACT"
    mv "$TEMP_EXTRACT"/metacubexd-gh-pages "$WEBUI_DIR"
    echo "$REMOTE_SHA" > "$WEBUI_SHA_FILE"
    rm -rf "$TEMP_ZIP" "$TEMP_EXTRACT"
    log_success "✅ WebUI 已更新至 ${REMOTE_SHA:0:8}"
    return 0
}

[ "$1" = "--update" ] && FORCE_UPDATE=true

# 更新间隔（秒）
UPDATE_INTERVAL=1500

echo ""
log_info "╔════════════════════════════════════════╗"
log_info "║  Clash TUN 启动脚本 (Clash Meta 内核)  ║"
log_info "╚════════════════════════════════════════╝"
echo ""

# 检查 root
[ "$(id -u)" -eq 0 ] || { log_error "请使用 sudo 运行此脚本"; exit 1; }

# 步骤 1：更新订阅
log_info "══════ 步骤 1/6：更新订阅 ══════"
if [ -n "$SUB_URL" ]; then
    HTTP_CODE=$(curl -s -o "$CLASH_CONFIG_FILE.tmp" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 --max-time 30 -L "$SUB_URL")
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

# 步骤 2：准备规则集
log_info "══════ 步骤 2/6：准备规则集 ══════"
[ "$FORCE_UPDATE" = true ] && rm -f "$CLASH_CONFIG_DIR/geosite.dat" "$CLASH_CONFIG_DIR/geoip.dat"
if [ ! -f "$CLASH_CONFIG_DIR/geosite.dat" ]; then
    log_info "下载 geosite.dat..."
    curl -s -L --retry 3 --connect-timeout 10 --max-time 120 -o "$CLASH_CONFIG_DIR/geosite.dat" "$GEOSITE_URL" && log_success "✅ geosite.dat 完成"
else log_info "geosite.dat 已存在"; fi
if [ ! -f "$CLASH_CONFIG_DIR/geoip.dat" ]; then
    log_info "下载 geoip.dat..."
    curl -s -L --retry 3 --connect-timeout 10 --max-time 120 -o "$CLASH_CONFIG_DIR/geoip.dat" "$GEOIP_URL" && log_success "✅ geoip.dat 完成"
else log_info "geoip.dat 已存在"; fi
echo ""

# 步骤 3：检查 TUN 设备
log_info "══════ 步骤 3/6：检查 TUN 设备 ══════"
[ -c "/dev/net/tun" ] || {
    mkdir -p /dev/net
    mknod /dev/net/tun c 10 200 2>/dev/null || true
    chmod 0666 /dev/net/tun
}
log_success "TUN 设备已就绪"
echo ""

# 步骤 4：停止进程与清理残留
log_info "══════ 步骤 4/6：停止进程与清理残留 ══════"
pkill -f clash-meta 2>/dev/null || true
sleep 2
ip link delete Meta 2>/dev/null || true
ip link delete Mihomo 2>/dev/null || true
sysctl -w net.ipv4.conf.all.route_localnet=1 >/dev/null 2>&1 || true
log_success "旧进程已清理，TUN 残留已回收"
echo ""

# 步骤 5：生成配置
log_info "══════ 步骤 5/6：生成 TUN 配置与性能优化 ══════"
[ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }
log_info "清理冲突并注入 NixOS 专属配置..."
process_config "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
log_success "配置已更新 (注入 TUN + Sniffer + DoH + Web UI + NixOS网卡修复)"
echo ""

# 步骤 5.5：WebUI 更新
log_info "══════ 步骤 5.5：WebUI 更新（后台执行） ══════"
check_update_webui &
WEBUI_PID=$!
log_info "WebUI 更新已在后台启动 (PID: $WEBUI_PID)，不阻塞核心启动"
echo ""

# 后台定时更新守护进程
auto_update_daemon() {
    set +e
    robust_sleep() {
        local target=$1
        local start=$(date +%s)
        while true; do
            local now=$(date +%s)
            local elapsed=$((now - start))
            local remaining=$((target - elapsed))
            if [ "$remaining" -le 0 ]; then break; fi
            sleep "$remaining" 2>/dev/null || true
        done
    }
    robust_sleep 60
    while true; do
        robust_sleep "$UPDATE_INTERVAL"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] 触发定时更新..." >> /tmp/clash-meta.log
        HTTP_CODE=$(curl -s -o "$CLASH_CONFIG_FILE.new" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 --max-time 30 -L "$SUB_URL")
        if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.new" ]; then
            mv "$CLASH_CONFIG_FILE.new" "$CLASH_CONFIG_FILE"
            process_config "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
            check_update_webui >> /tmp/clash-meta.log 2>&1
            UPDATE_SUCCESS=true
            PROXY_PROVIDERS=$(curl -s http://127.0.0.1:9090/providers/proxies)
            if [ -n "$PROXY_PROVIDERS" ] && [ "$PROXY_PROVIDERS" != "{}" ]; then
                NAMES=$(echo "$PROXY_PROVIDERS" | grep -oE '"[^"]+":{"type":"http' | sed -E 's/"([^"]+)".*/\1/')
                if [ -n "$NAMES" ]; then
                    while IFS= read -r name; do
                        CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://127.0.0.1:9090/providers/proxies/$name")
                        if [ "$CODE" != "200" ] && [ "$CODE" != "204" ]; then
                            UPDATE_SUCCESS=false
                        fi
                    done <<< "$NAMES"
                fi
            fi
            RULE_PROVIDERS=$(curl -s http://127.0.0.1:9090/providers/rules)
            if [ -n "$RULE_PROVIDERS" ] && [ "$RULE_PROVIDERS" != "{}" ]; then
                NAMES=$(echo "$RULE_PROVIDERS" | grep -oE '"[^"]+":{"type":"http' | sed -E 's/"([^"]+)".*/\1/')
                if [ -n "$NAMES" ]; then
                    while IFS= read -r name; do
                        CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://127.0.0.1:9090/providers/rules/$name")
                        if [ "$CODE" != "200" ] && [ "$CODE" != "204" ]; then
                            UPDATE_SUCCESS=false
                        fi
                    done <<< "$NAMES"
                fi
            fi
            if [ "$UPDATE_SUCCESS" = true ]; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ✅ 节点与规则热更新成功！" >> /tmp/clash-meta.log
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ⚠️ 部分 Provider 热更新失败" >> /tmp/clash-meta.log
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ❌ 订阅下载失败 (HTTP $HTTP_CODE)" >> /tmp/clash-meta.log
            rm -f "$CLASH_CONFIG_FILE.new"
        fi
    done
}

# 步骤 6：启动 clash-meta
log_info "══════ 步骤 6/6：启动 clash-meta ══════"
[ -x "$CLASH_META_BIN" ] || { log_error "未找到 clash-meta: $CLASH_META_BIN"; exit 1; }
nohup "$CLASH_META_BIN" -d "$CLASH_CONFIG_DIR" -f "$TEMP_CONFIG" > /tmp/clash-meta.log 2>&1 &
CLASH_PID=$!
echo "$CLASH_PID" > "$CLASH_PID_FILE"
log_success "Clash Meta 已启动 (PID: $CLASH_PID)"

sleep 8

log_info "验证运行状态..."
if ps -p $CLASH_PID > /dev/null 2>&1 && (ip link show Meta > /dev/null 2>&1 || ip link show Mihomo > /dev/null 2>&1); then
    log_success "✅ Clash Meta 运行正常"
    TUN_IFACE=$(ip link show | grep -oE 'Meta|Mihomo' | head -1)
    log_success "✅ TUN 接口已创建：$TUN_IFACE"
    echo ""
    log_info "测试外网连通性..."
    if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
        log_success "✅ Google 访问成功！TUN 全局接管完美！"
    else
        log_warn "⚠️ Google 访问失败，请在 GUI/WebUI 中切换可用节点"
    fi
    echo ""
    log_info "======================================"
    log_info "启动后台定时更新守护进程 (间隔: $((UPDATE_INTERVAL / 3600)) 小时)..."
    auto_update_daemon &
    disown
    log_info "等待 WebUI 更新完成 (最多30秒)..."
    wait_count=0
    while kill -0 $WEBUI_PID 2>/dev/null && [ $wait_count -lt 30 ]; do
        sleep 1
        wait_count=$((wait_count + 1))
    done
    if kill -0 $WEBUI_PID 2>/dev/null; then
        log_warn "⚠️ WebUI 更新超时，后台继续下载中，不影响使用"
    else
        wait $WEBUI_PID 2>/dev/null && log_success "✅ WebUI 更新完成" || log_warn "⚠️ WebUI 更新失败，不影响使用"
    fi
    echo ""
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
