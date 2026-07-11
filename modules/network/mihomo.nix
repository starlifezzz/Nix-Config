# /etc/nixos/modules/network/mihomo.nix
# ═══════════════════════════════════════════════════════════
# Mihomo (Clash.Meta) NixOS 原生模块
# 官方文档：https://search.nixos.org/options?query=services.mihomo
# ═══════════════════════════════════════════════════════════
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.mihomo;

  # ═══════════════════════════════════════════════════════════
  # 路径常量
  # ═══════════════════════════════════════════════════════════
  clashConfigDir = "/var/lib/mihomo";
  clashConfigFile = "${clashConfigDir}/config.yaml";
  # Clash Verge Rev 的配置源文件（脚本会读取并加工它）
  vergeConfigFile = "/home/zhangchongjie/.local/share/io.github.clash-verge-rev.clash-verge-rev/clash-verge-check.yaml";

  # ═══════════════════════════════════════════════════════════
  # 配置生成器脚本（从你的 bash 脚本提取的核心逻辑）
  # ═══════════════════════════════════════════════════════════
  mihomo-config-generator = pkgs.writeShellScriptBin "mihomo-config-generator" ''
    set -e

    RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[0;33m'; NC='\033[0m'
    log_info() { echo -e "''${BLUE}[INFO]''${NC} $1"; }
    log_success() { echo -e "''${GREEN}[SUCCESS]''${NC} $1"; }
    log_warn() { echo -e "''${YELLOW}[WARN]''${NC} $1"; }
    log_error() { echo -e "''${RED}[ERROR]''${NC} $1"; }

    CLASH_CONFIG_DIR="${clashConfigDir}"
    CLASH_CONFIG_FILE="${vergeConfigFile}"
    TARGET_CONFIG="${clashConfigFile}"

    # 订阅与规则配置
    SUB_URL=""
    SUB_UA="clash-verge/v2.4.5"
    GEOSITE_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geosite.dat"
    GEOIP_URL="https://cdn.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/geoip.dat"

    FORCE_UPDATE=false
    [ "$1" = "--update" ] && FORCE_UPDATE=true

    echo ""
    log_info "╔════════════════════════════════════════════╗"
    log_info "║  Mihomo 配置生成器 (NixOS systemd 模式)    ║"
    log_info "╚════════════════════════════════════════════╝"
    echo ""

    # ═══════════════════════════════════════════════════════════
    # 步骤 1：更新订阅
    # ═══════════════════════════════════════════════════════════
    log_info "══════ 步骤 1/4：更新订阅 ══════"
    if [ -n "$SUB_URL" ]; then
        HTTP_CODE=$(${pkgs.curl}/bin/curl -s -o "$CLASH_CONFIG_FILE.tmp" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 -L "$SUB_URL")
        if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.tmp" ]; then
            mv "$CLASH_CONFIG_FILE.tmp" "$CLASH_CONFIG_FILE"
            log_success "✅ 订阅下载成功 (HTTP $HTTP_CODE)"
        else
            log_warn "⚠️ 订阅下载失败，使用本地旧配置"
            rm -f "$CLASH_CONFIG_FILE.tmp"
        fi
    else
        log_warn "未配置订阅 URL，跳过（使用 Clash Verge Rev 现有配置）"
    fi
    echo ""

    # ═══════════════════════════════════════════════════════════
    # 步骤 2：准备规则集
    # ═══════════════════════════════════════════════════════════
    log_info "══════ 步骤 2/4：准备规则集 ══════"
    [ "$FORCE_UPDATE" = true ] && rm -f "$CLASH_CONFIG_DIR/geosite.dat" "$CLASH_CONFIG_DIR/geoip.dat"

    if [ ! -f "$CLASH_CONFIG_DIR/geosite.dat" ]; then
        log_info "下载 geosite.dat..."
        ${pkgs.curl}/bin/curl -s -L --retry 3 -o "$CLASH_CONFIG_DIR/geosite.dat" "$GEOSITE_URL" && log_success "✅ geosite.dat 完成"
    else log_info "geosite.dat 已存在"; fi

    if [ ! -f "$CLASH_CONFIG_DIR/geoip.dat" ]; then
        log_info "下载 geoip.dat..."
        ${pkgs.curl}/bin/curl -s -L --retry 3 -o "$CLASH_CONFIG_DIR/geoip.dat" "$GEOIP_URL" && log_success "✅ geoip.dat 完成"
    else log_info "geoip.dat 已存在"; fi
    echo ""

    # ═══════════════════════════════════════════════════════════
    # 步骤 3：检查 TUN 设备
    # ═══════════════════════════════════════════════════════════
    log_info "══════ 步骤 3/4：检查 TUN 设备 ══════"
    [ -c "/dev/net/tun" ] || {
        mkdir -p /dev/net
        mknod /dev/net/tun c 10 200 2>/dev/null || true
        chmod 0666 /dev/net/tun
    }
    log_success "TUN 设备已就绪"

    # 清理残留 TUN 接口
    ${pkgs.iproute2}/bin/ip link delete Meta 2>/dev/null || true
    ${pkgs.iproute2}/bin/ip link delete Mihomo 2>/dev/null || true
    ${pkgs.procps}/bin/sysctl -w net.ipv4.conf.all.route_localnet=1 >/dev/null 2>&1 || true
    echo ""

    # ═══════════════════════════════════════════════════════════
    # 步骤 4：生成 TUN 配置（配置加工厂）
    # ═══════════════════════════════════════════════════════════
    log_info "══════ 步骤 4/4：生成 TUN 配置与性能优化 ══════"
    [ -f "$CLASH_CONFIG_FILE" ] || { log_error "未找到配置文件：$CLASH_CONFIG_FILE"; exit 1; }

    log_info "清理冲突并注入 NixOS 专属配置..."

    # 配置加工厂：清理冲突 + 注入 NixOS 专属高性能配置
    ${pkgs.gawk}/bin/awk '
    # 1. 精准拦截并删除特定的顶级单行 Key
    /^(log-level|external-controller|secret|external-ui|external-ui-url|external-ui-name|fallback|fallback-filter):/ { next }

    # 2. 精准拦截并删除特定的顶级多行块
    /^(dns|tun|sniffer|profile):/ { skip=1; next }

    # 3. 遇到下一个真正的顶级 Key，关闭 skip 模式
    /^[a-zA-Z0-9_-]+:/ { skip=0 }

    # 4. 如果 skip 为 0，则打印该行
    !skip { print }
    ' "$CLASH_CONFIG_FILE" > "$TARGET_CONFIG"

    # 追加 NixOS 专属配置
    cat << 'EOF' >> "$TARGET_CONFIG"

# --- 🎛️ API 与 Web UI 面板配置 ---
external-controller: 127.0.0.1:9090
external-ui: ui
external-ui-url: "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

# --- 🚀 NixOS 专属高性能配置 ---
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

    log_success "✅ 配置已生成：$TARGET_CONFIG"
  '';

  # ═══════════════════════════════════════════════════════════
  # 热更新脚本（替代原脚本中的 auto_update_daemon 函数）
  # ═══════════════════════════════════════════════════════════
  mihomo-hot-reload = pkgs.writeShellScriptBin "mihomo-hot-reload" ''
    set +e

    CLASH_CONFIG_DIR="${clashConfigDir}"
    CLASH_CONFIG_FILE="${vergeConfigFile}"
    TARGET_CONFIG="${clashConfigFile}"
    SUB_URL=""
    SUB_UA="clash-verge/v2.4.5"

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] 触发定时更新..."

    # 1. 下载新订阅
    if [ -n "$SUB_URL" ]; then
        HTTP_CODE=$(${pkgs.curl}/bin/curl -s -o "$CLASH_CONFIG_FILE.new" -w "%{http_code}" -A "$SUB_UA" --connect-timeout 15 -L "$SUB_URL")
        if [ "$HTTP_CODE" -eq 200 ] && [ -s "$CLASH_CONFIG_FILE.new" ]; then
            mv "$CLASH_CONFIG_FILE.new" "$CLASH_CONFIG_FILE"
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] ✅ 订阅更新成功"
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] ❌ 订阅下载失败 (HTTP $HTTP_CODE)"
            rm -f "$CLASH_CONFIG_FILE.new"
            exit 1
        fi
    fi

    # 2. 重新生成配置
    ${mihomo-config-generator}/bin/mihomo-config-generator

    # 3. 热更新 Proxy Providers
    PROXY_PROVIDERS=$(${pkgs.curl}/bin/curl -s http://127.0.0.1:9090/providers/proxies)
    if [ -n "$PROXY_PROVIDERS" ] && [ "$PROXY_PROVIDERS" != "{}" ]; then
        NAMES=$(echo "$PROXY_PROVIDERS" | ${pkgs.gnugrep}/bin/grep -oE '"[^"]+":\{"type":"http' | ${pkgs.gnused}/bin/sed -E 's/"([^"]+)".*/\1/')
        if [ -n "$NAMES" ]; then
            while IFS= read -r name; do
                CODE=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" -X PUT "http://127.0.0.1:9090/providers/proxies/$name")
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] Provider '$name' 热更新: HTTP $CODE"
            done <<< "$NAMES"
        fi
    fi

    # 4. 热更新 Rule Providers
    RULE_PROVIDERS=$(${pkgs.curl}/bin/curl -s http://127.0.0.1:9090/providers/rules)
    if [ -n "$RULE_PROVIDERS" ] && [ "$RULE_PROVIDERS" != "{}" ]; then
        NAMES=$(echo "$RULE_PROVIDERS" | ${pkgs.gnugrep}/bin/grep -oE '"[^"]+":\{"type":"http' | ${pkgs.gnused}/bin/sed -E 's/"([^"]+)".*/\1/')
        if [ -n "$NAMES" ]; then
            while IFS= read -r name; do
                CODE=$(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" -X PUT "http://127.0.0.1:9090/providers/rules/$name")
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] Rule '$name' 热更新: HTTP $CODE"
            done <<< "$NAMES"
        fi
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [TIMER] ✅ 热更新流程完成"
  '';

in
{
  # ═══════════════════════════════════════════════════════════
  # ✅ Mihomo 系统级服务（NixOS 官方模块）
  # 官方文档：https://search.nixos.org/options?query=services.mihomo
  # ═══════════════════════════════════════════════════════════
  services.mihomo = {
    enable = true;
    configFile = clashConfigFile;
    webui = pkgs.metacubexd;
  };

  # ═══════════════════════════════════════════════════════════
  # systemd 服务覆盖：为 mihomo 添加 TUN 模式所需权限
  # ═══════════════════════════════════════════════════════════
  # mihomo 的 TUN 模式需要 CAP_NET_ADMIN（创建虚拟网卡、修改路由）
  # 和 CAP_NET_BIND_SERVICE（绑定低端口），以及 CAP_NET_RAW（DNS 劫持）
  systemd.services.mihomo = {
    # 确保配置生成器在 mihomo 启动前执行
    serviceConfig = {
      ExecStartPre = [
        # 在 mihomo 启动前，先运行配置生成器
        "+${mihomo-config-generator}/bin/mihomo-config-generator"
      ];
      # TUN 模式所需的最小权限集
      # 使用 "+" 前缀表示以 root 权限执行 ExecStartPre
      AmbientCapabilities = [
        "CAP_NET_ADMIN" # 创建 TUN 设备、修改路由表
        "CAP_NET_BIND_SERVICE" # 绑定低端口（DNS 劫持 53 端口）
        "CAP_NET_RAW" # 原始套接字（DNS 劫持）
      ];
      CapabilityBoundingSet = [
        "CAP_NET_ADMIN"
        "CAP_NET_BIND_SERVICE"
        "CAP_NET_RAW"
      ];
    };
    # 确保 mihomo 在网络就绪后启动
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
  };

  # ═══════════════════════════════════════════════════════════
  # systemd oneshot 服务：手动触发配置更新
  # 用法：sudo systemctl start mihomo-config-update
  # ═══════════════════════════════════════════════════════════
  systemd.services.mihomo-config-update = {
    description = "Mihomo 配置更新（订阅 + 规则集 + 配置加工）";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mihomo-config-generator}/bin/mihomo-config-generator --update";
    };
  };

  # ═══════════════════════════════════════════════════════════
  # systemd timer：定时热更新（替代原脚本的 auto_update_daemon）
  # ═══════════════════════════════════════════════════════════
  systemd.services.mihomo-hot-reload = {
    description = "Mihomo 热更新（Proxy/Rule Providers）";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mihomo-hot-reload}/bin/mihomo-hot-reload";
    };
  };

  systemd.timers.mihomo-hot-reload = {
    description = "Mihomo 定时热更新触发器";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # 每 25 分钟执行一次（对应原脚本的 UPDATE_INTERVAL=1500）
      OnUnitActiveSec = "25min";
      # 启动后延迟 1 分钟首次执行
      OnBootSec = "1min";
      # 持久化：如果错过了执行时间（如关机），开机后立即补执行
      Persistent = true;
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 创建配置目录（/var/lib/mihomo 由 services.mihomo 自动创建）
  # 确保目录权限正确
  # ═══════════════════════════════════════════════════════════
  systemd.tmpfiles.rules = [
    "d ${clashConfigDir} 0755 mihomo mihomo -"
  ];

  # ═══════════════════════════════════════════════════════════
  # 将工具脚本暴露到系统 PATH（方便手动调试）
  # ═══════════════════════════════════════════════════════════
  environment.systemPackages = [
    mihomo-config-generator
    mihomo-hot-reload
  ];
}