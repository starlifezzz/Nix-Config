#!/usr/bin/env bash
# /etc/nixos/scripts/detect-hardware.sh

set -euo pipefail

echo "=== NixOS Hardware Detection ===" >&2

# CPU 检测
detect_cpu() {
    if grep -q "AMD Ryzen 5 1600X" /proc/cpuinfo 2>/dev/null; then
        echo "ryzen-1600x"
        echo "✓ Detected: AMD Ryzen 5 1600X" >&2
    elif grep -q "AMD Ryzen 5 2600" /proc/cpuinfo 2>/dev/null; then
        echo "ryzen-2600"
        echo "✓ Detected: AMD Ryzen 5 2600" >&2
    elif grep -q "AMD Ryzen 5 3600" /proc/cpuinfo 2>/dev/null; then
        echo "ryzen-3600"
        echo "✓ Detected: AMD Ryzen 5 3600" >&2
    else
        echo "unknown-cpu"
        echo "⚠ Unknown CPU detected" >&2
    fi
}

#!/bin/bash
# GPU 硬件识别码检测脚本

detect_gpu() {
    # 检查 lspci 是否可用
    if ! command -v lspci &>/dev/null; then
        echo "unknown-gpu"
        echo "⚠ lspci not available" >&2
        return 1
    fi

    # 获取 AMD GPU 的硬件识别码 (Vendor ID:Device ID)
    # 1002 = AMD Vendor ID
    local gpu_id
    gpu_id=$(lspci -nn 2>/dev/null | awk '/\[1002:[0-9a-fA-F]+\]/ && /VGA|Display/ {
        match($0, /\[1002:([0-9a-fA-F]+)\]/, arr)
        if (arr[1] != "") {
            print arr[1]
            exit
        }
    }')

    # 如果上面的方法不行，用 grep 提取
    if [[ -z "$gpu_id" ]]; then
        gpu_id=$(lspci -nn 2>/dev/null | grep -oP '\[1002:\K[0-9a-fA-F]+' | head -1)
    fi

    if [[ -z "$gpu_id" ]]; then
        echo "unknown-gpu"
        echo "⚠ No AMD GPU detected" >&2
        return 1
    fi

    # 转换为小写便于比较
    gpu_id=$(echo "$gpu_id" | tr '[:upper:]' '[:lower:]')

    # 根据 Device ID 映射到具体型号
    case "$gpu_id" in
        # RDNA 4 (RX 9000 系列)
        "7600"|"7601"|"7602"|"7603"|"7604")
            echo "rx-9070-xt"
            echo "✓ Detected: AMD Radeon RX 9070 XT [1002:$gpu_id]" >&2
            ;;
        "7605"|"7606"|"7607")
            echo "rx-9070"
            echo "✓ Detected: AMD Radeon RX 9070 [1002:$gpu_id]" >&2
            ;;
        "7608"|"7609")
            echo "rx-9060-xt"
            echo "✓ Detected: AMD Radeon RX 9060 XT [1002:$gpu_id]" >&2
            ;;

        # RDNA 3 (RX 7000 系列)
        "7300"|"7301"|"7302"|"7303"|"7304")
            echo "rx-7900-xtx"
            echo "✓ Detected: AMD Radeon RX 7900 XTX [1002:$gpu_id]" >&2
            ;;
        "7305"|"7306"|"7307")
            echo "rx-7900-xt"
            echo "✓ Detected: AMD Radeon RX 7900 XT [1002:$gpu_id]" >&2
            ;;
        "7308"|"7309"|"730a"|"730b")
            echo "rx-7800-xt"
            echo "✓ Detected: AMD Radeon RX 7800 XT [1002:$gpu_id]" >&2
            ;;
        "730c"|"730d"|"730e")
            echo "rx-7700-xt"
            echo "✓ Detected: AMD Radeon RX 7700 XT [1002:$gpu_id]" >&2
            ;;
        "730f"|"7310"|"7311")
            echo "rx-7600"
            echo "✓ Detected: AMD Radeon RX 7600 [1002:$gpu_id]" >&2
            ;;

       # RDNA 2 (RX 6000 系列)
        "731f")
            echo "rx-5500xt"
            echo "✓ Detected: AMD Radeon RX 5500 XT [1002:$gpu_id]" >&2
            ;;
        "732d"|"732e"|"732f")
            echo "rx-6600xt"
            echo "✓ Detected: AMD Radeon RX 6600 XT [1002:$gpu_id]" >&2
            ;;
        "7330"|"7331")
            echo "rx-6600"
            echo "✓ Detected: AMD Radeon RX 6600 [1002:$gpu_id]" >&2
            ;;
            
        # RDNA 1 (RX 5000 系列) - Navi 14
        "7340"|"7341")
            echo "rx-5500"
            echo "✓ Detected: AMD Radeon RX 5500 [1002:$gpu_id]" >&2
            ;;
        "7342"|"7343")
            echo "rx-5700"
            echo "✓ Detected: AMD Radeon RX 5700 [1002:$gpu_id]" >&2
            ;;
        "7344"|"7345")
            echo "rx-5600"
            echo "✓ Detected: AMD Radeon RX 5600 [1002:$gpu_id]" >&2
            ;;
        "7346"|"7347")
            echo "rx-5600-xt"
            echo "✓ Detected: AMD Radeon RX 5600 XT [1002:$gpu_id]" >&2
            ;;
        "7348"|"7349")
            echo "rx-5700-xt"
            echo "✓ Detected: AMD Radeon RX 5700 XT [1002:$gpu_id]" >&2
            ;;
        
        # Polaris (RX 400/500 系列)
        "66af"|"66b0"|"66b1")
            echo "r9-370"
            echo "✓ Detected: AMD Radeon R9 370 [1002:$gpu_id]" >&2
            ;;
        "67df"|"67ef")
            echo "rx-470"
            echo "✓ Detected: AMD Radeon RX 470 [1002:$gpu_id]" >&2
            ;;
        "67e0"|"67e1")
            echo "rx-480"
            echo "✓ Detected: AMD Radeon RX 480 [1002:$gpu_id]" >&2
            ;;
        "67ff"|"67ef")
            echo "rx-570"
            echo "✓ Detected: AMD Radeon RX 570 [1002:$gpu_id]" >&2
            ;;
        "67df"|"67ef")
            echo "rx-580"
            echo "✓ Detected: AMD Radeon RX 580 [1002:$gpu_id]" >&2
            ;;
           # 未识别
        *)
            echo "unknown-gpu"
            echo "⚠ Unknown AMD GPU Device ID: 1002:$gpu_id" >&2
            ;;
    esac
}


# 主程序
CPU_MODEL=$(detect_cpu)
GPU_MODEL=$(detect_gpu)

echo "" >&2
echo "═══════════════════════════════════════════════════════" >&2
echo "Detection Results:" >&2
echo "  CPU: $CPU_MODEL" >&2
echo "  GPU: $GPU_MODEL" >&2
echo "═══════════════════════════════════════════════════════" >&2

# 输出为 Nix 可读的格式
cat <<EOF
{
  cpuModel = "$CPU_MODEL";
  gpuModel = "$GPU_MODEL";
}
EOF