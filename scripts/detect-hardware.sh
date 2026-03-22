#!/usr/bin/env bash
# /etc/nixos/scripts/detect-hardware.sh

set -euo pipefail

echo "=== NixOS Hardware Detection ===" >&2
echo "" >&2

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

# GPU 检测
detect_gpu() {
    if ! command -v lspci &>/dev/null; then
        echo "unknown-gpu"
        echo "⚠ lspci not available - install pciutils package" >&2
        return 1
    fi

    local gpu_id
    gpu_id=$(lspci -nn 2>/dev/null | awk '/\[1002:[0-9a-fA-F]+\]/ && /VGA|Display/ {
        match($0, /\[1002:([0-9a-fA-F]+)\]/, arr)
        if (arr[1] != "") {
            print arr[1]
            exit
        }
    }')

    if [[ -z "$gpu_id" ]]; then
        gpu_id=$(lspci -nn 2>/dev/null | grep '\[1002:' | head -1 | sed 's/.*\[1002:\([0-9a-fA-F]*\).*/\1/' | tr '[:upper:]' '[:lower:]')
    fi

    if [[ -z "$gpu_id" ]]; then
        echo "unknown-gpu"
        echo "⚠ No AMD GPU detected" >&2
        return 1
    fi

    gpu_id=$(echo "$gpu_id" | tr '[:upper:]' '[:lower:]')

    case "$gpu_id" in
        "7310"|"7311")
            echo "rx-5600-xt"
            echo "✓ Detected: AMD Radeon RX 5600 XT [1002:$gpu_id]" >&2
            ;;
        "731e"|"731f")
            echo "rx-5500-xt"
            echo "✓ Detected: AMD Radeon RX 5500 XT [1002:$gpu_id]" >&2
            ;;
        "7340"|"7341")
            echo "rx-5700-xt"
            echo "✓ Detected: AMD Radeon RX 5700 XT [1002:$gpu_id]" >&2
            ;;
        "7342"|"7343")
            echo "rx-5700"
            echo "✓ Detected: AMD Radeon RX 5700 [1002:$gpu_id]" >&2
            ;;
        "7344"|"7345")
            echo "rx-5600"
            echo "✓ Detected: AMD Radeon RX 5600 [1002:$gpu_id]" >&2
            ;;
        "7320"|"7321"|"7322")
            echo "rx-6900-xt"
            echo "✓ Detected: AMD Radeon RX 6900 XT [1002:$gpu_id]" >&2
            ;;
        "7323"|"7324"|"7325")
            echo "rx-6800-xt"
            echo "✓ Detected: AMD Radeon RX 6800 XT [1002:$gpu_id]" >&2
            ;;
        "7326"|"7327")
            echo "rx-6800"
            echo "✓ Detected: AMD Radeon RX 6800 [1002:$gpu_id]" >&2
            ;;
        "7328"|"7329"|"732a")
            echo "rx-6700-xt"
            echo "✓ Detected: AMD Radeon RX 6700 XT [1002:$gpu_id]" >&2
            ;;
        "732b"|"732c")
            echo "rx-6700"
            echo "✓ Detected: AMD Radeon RX 6700 [1002:$gpu_id]" >&2
            ;;
        "732d"|"732e"|"732f")
            echo "rx-6600-xt"
            echo "✓ Detected: AMD Radeon RX 6600 XT [1002:$gpu_id]" >&2
            ;;
        "7330"|"7331")
            echo "rx-6600"
            echo "✓ Detected: AMD Radeon RX 6600 [1002:$gpu_id]" >&2
            ;;
        "7332"|"7333")
            echo "rx-6500-xt"
            echo "✓ Detected: AMD Radeon RX 6500 XT [1002:$gpu_id]" >&2
            ;;
        "7334"|"7335")
            echo "rx-6400"
            echo "✓ Detected: AMD Radeon RX 6400 [1002:$gpu_id]" >&2
            ;;
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
        "67ff")
            echo "rx-570"
            echo "✓ Detected: AMD Radeon RX 570 [1002:$gpu_id]" >&2
            ;;
        *)
            echo "unknown-gpu"
            echo "⚠ Unknown AMD GPU Device ID: 1002:$gpu_id" >&2
            ;;
    esac
}

main() {
    CPU_MODEL=$(detect_cpu)
    GPU_MODEL=$(detect_gpu)

    echo "" >&2
    echo "═══════════════════════════════════════════════════════" >&2
    echo "Detection Results:" >&2
    echo "  CPU: $CPU_MODEL" >&2
    echo "  GPU: $GPU_MODEL" >&2
    echo "═══════════════════════════════════════════════════════" >&2

    cat <<EOF
{ config, lib, pkgs, ... }:

{
  hardware.cpu.manualModel = lib.mkDefault "$CPU_MODEL";
  hardware.gpu.manualModel = lib.mkDefault "$GPU_MODEL";
  
  networking.hostName = lib.mkDefault ("nixos-" + "$CPU_MODEL" + "-" + "$GPU_MODEL");
}
EOF
}

main "$@"