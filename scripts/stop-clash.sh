#!/usr/bin/env bash
# 一键关闭 Clash Meta（内核 + WebUI + TUN + 守护进程）

# 禁用 bash job control 通知，防止 "已杀死" 消息
set +m

echo ""
echo "🛑 正在关闭 Clash Meta..."

KILLED=0

# 1. 关闭 clash-meta / mihomo 进程（WebUI 随之关闭）
for name in clash-meta mihomo; do
    pids=$(pgrep -x "$name" 2>/dev/null)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs sudo kill -9 2>/dev/null
        echo "  ✅ $name 进程已终止"
        KILLED=1
    fi
done

# 2. 关闭后台定时更新守护进程
pids=$(pgrep -f "start-clash-tun" 2>/dev/null | grep -v $$)
if [ -n "$pids" ]; then
    echo "$pids" | xargs sudo kill -9 2>/dev/null
    echo "  ✅ 后台守护进程已终止"
    KILLED=1
fi

# 3. 清理残留的 TUN 接口
if ip link show Meta >/dev/null 2>&1; then
    sudo ip link delete Meta 2>/dev/null
    echo "  ✅ TUN 接口 Meta 已清理"
    KILLED=1
fi

if [ "$KILLED" -eq 0 ]; then
    echo "  ℹ️  Clash Meta 未在运行"
fi

# 4. 清理当前 shell 代理环境变量
unset http_proxy https_proxy all_proxy HTTP_PROXY HTTPS_PROXY ALL_PROXY 2>/dev/null
echo "  ✅ Shell 代理环境变量已清除"

echo ""
echo "🎉 Clash Meta 及 WebUI 已完全关闭"
echo ""