#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Clash TUN 模式快速检查脚本
# ═══════════════════════════════════════════════════════════

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo ""
echo -e "${BLUE}========== Clash TUN 快速检查 ==========${NC}"
echo ""

# 1. 检查 TUN 设备
echo -n "TUN 设备 (/dev/net/tun): "
if [ -c "/dev/net/tun" ]; then
    echo -e "${GREEN}✓ 存在${NC}"
else
    echo -e "${RED}✗ 不存在${NC}"
fi

# 2. 检查 TUN 网络接口
echo -n "TUN 网络接口："
TUN_IFACE=$(ip link show | grep -oE 'Meta|clash[0-9]*|utun[0-9]*' | head -1)
if [ -n "$TUN_IFACE" ]; then
    echo -e "${GREEN}✓ $TUN_IFACE${NC}"
else
    echo -e "${YELLOW}○ 未检测到（可能尚未启动）${NC}"
fi

# 3. 检查 Clash 进程
echo -n "Clash 进程："
if pgrep -f "clash" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 运行中${NC}"
    pgrep -a "clash" | head -3
else
    echo -e "${YELLOW}○ 未运行${NC}"
fi

# 4. 检查代理端口
echo -n "代理端口 (7897): "
if ss -tlnp | grep -q ":7897"; then
    echo -e "${GREEN}✓ 监听中${NC}"
else
    echo -e "${YELLOW}○ 未监听${NC}"
fi

# 5. 检查防火墙规则
echo -n "防火墙 TUN 接口规则："
if sudo nft list ruleset | grep -qE 'Meta|clash|utun'; then
    echo -e "${GREEN}✓ 已配置${NC}"
else
    echo -e "${YELLOW}○ 未检测到${NC}"
fi

# 6. 测试 Google 访问
echo ""
echo -n "测试 Google 访问："
export http_proxy="http://127.0.0.1:7897"
export https_proxy="http://127.0.0.1:7897"

if curl -s --connect-timeout 5 -I https://www.google.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ 成功！${NC}"
else
    echo -e "${RED}❌ 失败${NC}"
    echo "   请检查："
    echo "   1. Clash Verge Rev 是否选择了节点"
    echo "   2. 机场订阅是否有效"
fi

unset http_proxy
unset https_proxy

echo ""
echo -e "${BLUE}======================================${NC}"
echo ""
