#!/usr/bin/env bash
# 一键关闭 Clash Meta（内核 + WebUI + TUN + 守护进程）

echo ""
echo "🛑 正在关闭 Clash Meta..."

# 1. 杀掉所有 clash-meta / mihomo 进程（WebUI 随之关闭）
FOUND=0
if pgrep -f clash-meta >/dev/null 2>&1; then
    sudo pkill -9 -f clash-meta 2>/dev/null
    echo "  ✅ clash-meta 进程已终止"
    FOUND=1
fi
if pgrep -f mihomo >/dev/null 2>&1; then
    sudo pkill -9 -f mihomo 2>/dev/null
    echo "  ✅ mihomo 进程已终止"
    FOUND=1
fi

# 2. 杀掉后台定时更新守护进程
if pgrep -f "start-clash-tun" >/dev/null 2>&1; then
    sudo pkill -9 -f "start-clash-tun" 2>/dev/null
    echo "  ✅ 后台守护进程已终止"
    FOUND=1
fi

# 3. 清理残留的 TUN 接口
if ip link show Meta >/dev/null 2>&1; then
    sudo ip link delete Meta 2>/dev/null
    echo "  ✅ TUN 接口 Meta 已清理"
    FOUND=1
fi

if [ "$FOUND" -eq 0 ]; then
    echo "  ℹ️  Clash Meta 未在运行"
fi

# 4. 清理代理环境变量
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY 2>/dev/null
echo "  ✅ Shell 代理环境变量已清除"

echo ""
echo "🎉 Clash Meta 及 WebUI 已完全关闭"
echo ""