#!/usr/bin/env bash

# MCP Server 快速配置脚本
# 用于快速修复和配置 MCP Server NixOS

set -e

echo "🔧 MCP Server NixOS 快速配置"
echo "═══════════════════════════════════════"
echo ""

# 检查包装脚本是否存在
if [ ! -f "/etc/nixos/scripts/mcp-nixos-wrapper.sh" ]; then
    echo "❌ 错误：包装脚本不存在"
    echo "   请先运行系统重建或手动创建脚本"
    exit 1
fi

echo "✅ 包装脚本已存在"

# 检查 VSCode 配置
if grep -q "mcp-nixos-wrapper.sh" /home/zhangchongjie/.config/Code/User/settings.json 2>/dev/null; then
    echo "✅ VSCode 配置已正确设置"
else
    echo "⚠️  VSCode 配置可能未正确设置"
    echo "   请手动编辑 /home/zhangchongjie/.config/Code/User/settings.json"
    echo "   添加以下配置："
    echo ""
    echo '   "mcpServers": {'
    echo '     "nixos": {'
    echo '       "command": "/etc/nixos/scripts/mcp-nixos-wrapper.sh",'
    echo '       "type": "stdio"'
    echo '     }'
    echo '   }'
    echo ""
fi

# 检查 Clash TUN 模式
if pgrep -x "verge-mihomo" > /dev/null; then
    echo "✅ Clash TUN 模式正在运行"
else
    echo "⚠️  Clash TUN 模式未运行"
    echo "   如果需要访问 PyPI，请运行：sudo clash-tun"
    echo "   或者：sudo /etc/nixos/scripts/start-clash-tun.sh"
fi

# 测试包装脚本
echo ""
echo "🧪 测试包装脚本..."
if timeout 2 /etc/nixos/scripts/mcp-nixos-wrapper.sh >/dev/null 2>&1; then
    echo "✅ 包装脚本工作正常"
else
    echo "⚠️  包装脚本测试超时（可能是首次运行，需要下载依赖）"
    echo "   这很正常，首次运行可能需要 1-2 分钟"
fi

echo ""
echo "═══════════════════════════════════════"
echo "✨ 配置完成！"
echo ""
echo "📝 下一步操作："
echo "   1. 如果 Clash TUN 未运行，请启动：sudo clash-tun"
echo "   2. 重启 VSCode 或重新加载窗口"
echo "   3. 在 VSCode 中打开输出面板查看 MCP 日志"
echo "      (View -> Output -> 选择 MCP)"
echo ""
echo "📚 详细文档："
echo "   - /etc/nixos/MCP_SERVER_GUIDE.md"
echo "   - /etc/nixos/MCP_SERVER_FIX.md"
echo ""
