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


# !/bin/sh
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
[ "$1" = "--update" ] && FORCE_UPDATE=true

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

# ═══════════════════════════════════════════════════════════
# 4. 停止现有进程并重置网络 (最初版本灵魂逻辑！)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 4/6：停止进程与重置网络 ══════"
pkill -f clash-meta 2>/dev/null || true
sleep 2
# ⚠️ 关键：重置 NetworkManager 防止 TUN 路由死锁
nmcli networking off && sleep 1 && nmcli networking on
systemctl restart systemd-resolved
sleep 2
log_success "旧进程已清理，网络已重置"
echo ""


# ═══════════════════════════════════════════════════════════
# 5. 生成 TUN 配置 (修复 YAML 重复 Key 报错 + 性能优化)
# ═══════════════════════════════════════════════════════════
log_info "══════ 步骤 5/6：生成 TUN 配置与性能优化 ══════"
[ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }

cp "$CLASH_CONFIG_FILE" "$TEMP_CONFIG"

# 🛠️ 核心修复：清理原文件中的冲突配置，防止 YAML 重复 Key 报错
log_info "清理原文件中的基础配置 (dns, log-level)..."

# 1. 删除原文件的 log-level 行
sed -i '/^log-level:/d' "$TEMP_CONFIG"

# 2. 删除原文件的整个 dns: 块 (从 dns: 开始，直到遇到下一个不缩进的顶级字母)
# 原理：匹配 ^dns: 到 ^[a-zA-Z] 之间的所有行并删除
sed -i '/^dns:/,/^[a-zA-Z]/ { /^dns:/d; /^[a-zA-Z]/!d; }' "$TEMP_CONFIG"

# 3. 清理可能残留的旧 tun: 和 sniffer: 块 (防止多次运行导致重复)
sed -i '/^tun:/,/^[a-zA-Z]/ { /^tun:/d; /^[a-zA-Z]/!d; }' "$TEMP_CONFIG"
sed -i '/^sniffer:/,/^[a-zA-Z]/ { /^sniffer:/d; /^[a-zA-Z]/!d; }' "$TEMP_CONFIG"
sed -i '/^profile:/,/^[a-zA-Z]/ { /^profile:/d; /^[a-zA-Z]/!d; }' "$TEMP_CONFIG"

log_success "原文件冲突配置已清理"

# 🚀 追加 NixOS 专属高性能配置 (现在不会报重复错了)
cat << 'EOF' >> "$TEMP_CONFIG"

# --- 🚀 脚本自动注入：NixOS 专属高性能配置 ---

# 1. 基础性能与日志优化
log-level: warning             # ⬇️ 降低日志级别，减少高负载下的磁盘 IO 损耗
tcp-concurrent: true           # ⬆️ 开启 TCP 并发，显著提升多连接下载速度
unified-delay: true            # ⬆️ 开启统一延迟，节点测速更准确
find-process-mode: off         # ⬇️ 关闭进程匹配，大幅降低 CPU 占用（桌面端推荐）

# 2. 缓存与状态持久化（防止切换节点断流）
profile:
  store-selected: true         # 记住你手动选择的节点
  store-fake-ip: true          # 持久化 Fake-IP，重启后不用重新解析

# 3. 核心：Sniffer 嗅探器（Fake-IP 模式的救命稻草）
sniffer:
  enable: true                 # ⬆️ 必须开启！还原真实域名，防止 Fake-IP 导致游戏/应用断网
  sniff:
    HTTP: { ports: [80, 8080-8880], override-destination: true }
    TLS:  { ports: [443, 8443] }
    QUIC: { ports: [443, 8443] }
  skip-domain:                 # 跳过不需要嗅探的域名（如微软系、苹果系，防止证书报错）
    - "Mijia Cloud"
    - "+.push.apple.com"

# 4. 现代 DNS 架构（防劫持 + 防死锁 + 国内外分流）
dns:
  enable: true
  ipv6: false
  prefer-h3: true
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16
  fake-ip-filter:              # 🛡️ 保护本地局域网、系统探活和节点域名不走 Fake-IP
    - '*.lan'
    - '*.local'
    - 'localhost.ptlogin2.qq.com'
    - '+.stun.*.*'
    - '+.stun.*.*.*'
    - '+.dnscloudcloud.top'    # 🆕 关键：让你的机场节点域名返回真实 IP
    - 'detectportal.firefox.com' # 🆕 关键：Firefox 网络探活域名
    - '+.push.apple.com'
  default-nameserver: [223.5.5.5, 119.29.29.29]
  
  # 🆕 核心修复：专门用于解析代理节点域名的 DNS（必须是纯 IP，不能用 DoH）
  # 这能防止“节点连不上导致 DNS 不通，DNS 不通导致节点连不上”的死锁！
  proxy-server-nameserver:
    - 223.5.5.5
    - 119.29.29.29
    - 114.114.114.114
  respect-rules: true          # 🆕 让 DNS 解析也遵循分流规则，提升准确性

  nameserver:                  # 国内域名走国内 DoH (防污染)
    - "https://doh.pub/dns-query"
    - "https://dns.alidns.com/dns-query"
  nameserver-policy:           # 🌟 现代分流策略：精准匹配
    "geosite:cn,private":      # 国内和私有网络走国内 DoH
      - "https://doh.pub/dns-query"
      - "https://dns.alidns.com/dns-query"
    "geosite:geolocation-!cn": # 国外域名走国际 DoH (Cloudflare/Google)
      - "https://1.1.1.1/dns-query"
      - "https://8.8.8.8/dns-query"

# 5. TUN 虚拟网卡（全局接管核心）
tun:
  enable: true
  stack: system                # system 栈性能最高
  auto-route: true
  auto-detect-interface: true
  strict-route: true
  dns-hijack:                  # 劫持所有 DNS 请求，防止 DNS 泄漏
    - any:53
EOF

log_success "配置已更新 (注入 TUN + Sniffer + DoH3 + 并发优化)"
echo ""


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