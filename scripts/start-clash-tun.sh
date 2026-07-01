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
CLASH_CONFIG_DIR="$HOME/.local/share/io.github.clash-verge-rev.clash-verge-rev"
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
    
    # 🌟 核心修复：补全了第 2 步的多行块拦截规则
    awk '
    # 1. 精准拦截并删除特定的顶级单行 Key (行首无空格)
    /^(log-level|external-controller|secret|external-ui|external-ui-url|external-ui-name|fallback|fallback-filter):/ { next }

    # 2. 🌟 精准拦截并删除特定的顶级多行块 (行首无空格，开启 skip 模式)
    /^(dns|tun|sniffer|profile):/ { skip=1; next }

    # 3. 遇到下一个真正的顶级 Key (行首是字母/数字/下划线/连字符，且无空格)，关闭 skip 模式
    /^[a-zA-Z0-9_-]+:/ { skip=0 }

    # 4. 如果 skip 为 0，则打印该行
    !skip { print }
    ' "$SOURCE_FILE" > "$TARGET_FILE"

    # 追加我们的完美 NixOS 专属配置
    cat << 'EOF' >> "$TARGET_FILE"

# --- 🎛️ API 与 Web UI 面板配置 ---
external-controller: 127.0.0.1:9090
external-ui: ui
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# --- 🚀 脚本自动注入：NixOS 专属高性能配置 ---
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
# 🌟 后台守护函数：定时更新订阅 + API 热重载 (防弹不死鸟版)
# ═══════════════════════════════════════════════════════════
auto_update_daemon() {
    # 🛡️ 核心防御 1：在子 Shell 中强制关闭 set -e，防止任何报错导致守护进程自杀
    set +e 
    
    # 🛡️ 核心防御 2：防惊醒睡眠函数 (免疫 SIGCHLD 等信号中断)
    robust_sleep() {
        local target=$1
        local start=$(date +%s)
        while true; do
            local now=$(date +%s)
            local elapsed=$((now - start))
            local remaining=$((target - elapsed))
            if [ "$remaining" -le 0 ]; then break; fi
            sleep "$remaining" 2>/dev/null || true # 即使被信号打断，也会计算剩余时间继续睡
        done
    }

    # 首次启动延迟 60 秒，等待内核与 TUN 路由完全稳定
    robust_sleep 60 
    
    while true; do
        robust_sleep "$UPDATE_INTERVAL"
        
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] 触发定时更新..." >> /tmp/clash-meta.log
        
        # 1. 下载新订阅到临时文件
        HTTP_CODE=$(curl -s -o "$CLASH_CONFIG_FILE.new" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 -L "$SUB_URL")
        
        if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.new" ]; then
            # 2. 替换基础订阅文件并重新加工
            mv "$CLASH_CONFIG_FILE.new" "$CLASH_CONFIG_FILE"
            process_config "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"
            
            # 🌟 3. 侦察-打击模式：热更新 Proxy Providers 和 Rule Providers
            UPDATE_SUCCESS=true
            
            # 侦察并更新 Proxy Providers
            PROXY_PROVIDERS=$(curl -s http://127.0.0.1:9090/providers/proxies)
            if [ -n "$PROXY_PROVIDERS" ] && [ "$PROXY_PROVIDERS" != "{}" ]; then
                # 提取所有 provider 的 name (使用 grep 和 sed 解析 JSON 的 keys)
                NAMES=$(echo "$PROXY_PROVIDERS" | grep -oE '"[^"]+":\{"type":"http' | sed -E 's/"([^"]+)".*/\1/')
                if [ -n "$NAMES" ]; then
                    while IFS= read -r name; do
                        CODE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "http://127.0.0.1:9090/providers/proxies/$name")
                        if [ "$CODE" != "200" ] && [ "$CODE" != "204" ]; then
                            UPDATE_SUCCESS=false
                        fi
                    done <<< "$NAMES"
                fi
            fi
            
            # 侦察并更新 Rule Providers (规则集)
            RULE_PROVIDERS=$(curl -s http://127.0.0.1:9090/providers/rules)
            if [ -n "$RULE_PROVIDERS" ] && [ "$RULE_PROVIDERS" != "{}" ]; then
                NAMES=$(echo "$RULE_PROVIDERS" | grep -oE '"[^"]+":\{"type":"http' | sed -E 's/"([^"]+)".*/\1/')
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
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ✅ 节点与规则热更新成功！(TUN 路由保持稳定，未触发重启)" >> /tmp/clash-meta.log
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [DAEMON] ⚠️ 部分 Provider 热更新失败或无 Provider，配置已保存，下次重启生效" >> /tmp/clash-meta.log
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