#!/usr/bin/env bash
# /etc/nixos/scripts/switch-hardware.sh
# 灵活的硬件配置切换工具

set -euo pipefail

cd /etc/nixos

echo ""
echo "═══════════════════════════════════════════════════════"
echo "       NixOS 硬件配置切换"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "可用的硬件配置:"
echo ""
echo "  1) 1600X + R9 370   (nixos-1600x-r9370)"
echo "  2) 2600 + RX 5500   (nixos-2600-rx5500) ← 当前"
echo "  3) 2600 + RX 6600XT (nixos-2600-rx6600xt) ← 升级"
echo "  4) 3600 + RX 6600XT (nixos-3600-rx6600xt)"
echo ""
echo "  q) 退出"
echo ""

read -rp "请选择配置 [1-4]: " choice

case $choice in
    1)
        CONFIG="nixos-1600x-r9370"
        ;;
    2)
        CONFIG="nixos-2600-rx5500"
        ;;
    3)
        CONFIG="nixos-2600-rx6600xt"
        ;;
    4)
        CONFIG="nixos-3600-rx6600xt"
        ;;
    q|Q)
        echo "退出"
        exit 0
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac

echo ""
echo "正在切换到配置：$CONFIG"
echo ""

# 使用 flake.nix 还是 flake-hardware.nix？
if [[ -f "flake.nix" ]]; then
    FLAKE_FILE="flake.nix"
else
    FLAKE_FILE="modules/flake-hardware.nix"
fi

echo "使用配置文件：$FLAKE_FILE"
echo ""

# 重建系统
sudo nixos-rebuild switch --flake ".#$CONFIG"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✓ 切换完成！"
echo "  新配置：$CONFIG"
echo "  主机名：$(hostname)"
echo "═══════════════════════════════════════════════════════"