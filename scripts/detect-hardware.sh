#!/usr/bin/env bash
# /etc/nixos/scripts/detect-hardware.sh
# NixOS 硬件自动检测脚本 - 支持多设备动态配置

set -euo pipefail

OUTPUT_DIR="/etc/nixos"
LOG_FILE="$OUTPUT_DIR/hardware-detect.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# CPU 检测
detect_cpu() {
    log "正在检测 CPU..."
    
    if grep -q "AMD Ryzen 5 1600X" /proc/cpuinfo 2>/dev/null; then
        log "✓ 检测到：AMD Ryzen 5 1600X"
        echo "ryzen-1600x"
    elif grep -q "AMD Ryzen 5 2600" /proc/cpuinfo 2>/dev/null; then
        log "✓ 检测到：AMD Ryzen 5 2600"
        echo "ryzen-2600"
    elif grep -q "AMD Ryzen 5 3600" /proc/cpuinfo 2>/dev/null; then
        log "✓ 检测到：AMD Ryzen 5 3600"
        echo "ryzen-3600"
    else
        log "⚠ 未识别的 CPU"
        echo "unknown-cpu"
    fi
}

# GPU 检测
detect_gpu() {
    log "正在检测 GPU..."
    
    if ! command -v lspci &>/dev/null; then
        log "⚠ lspci 不可用 - 请安装 pciutils"
        echo "unknown-gpu"
        return 1
    fi

    local gpu_id
    gpu_id=$(lspci -nn 2>/dev/null | grep '\[1002:' | head -1 | sed 's/.*\[1002:\([0-9a-fA-F]*\).*/\1/' | tr '[:upper:]' '[:lower:]')

    if [[ -z "$gpu_id" ]]; then
        log "⚠ 未检测到 AMD GPU"
        echo "unknown-gpu"
        return 1
    fi

    log "检测到 AMD GPU Device ID: 1002:$gpu_id"

    case "$gpu_id" in
        # Polaris (R9 370, RX 470/480/570)
        "66af"|"66b0"|"66b1")
            log "✓ 检测到：AMD Radeon R9 370"
            echo "r9-370"
            ;;
        "67df"|"67ef")
            log "✓ 检测到：AMD Radeon RX 470"
            echo "rx-470"
            ;;
        "67e0"|"67e1")
            log "✓ 检测到：AMD Radeon RX 480"
            echo "rx-480"
            ;;
        "67ff")
            log "✓ 检测到：AMD Radeon RX 570"
            echo "rx-570"
            ;;

        # RDNA 1 (RX 5500/5600/5700)
        "7310"|"7311")
            log "✓ 检测到：AMD Radeon RX 5600 XT"
            echo "rx-5600-xt"
            ;;
        "731e"|"731f")
            log "✓ 检测到：AMD Radeon RX 5500 XT"
            echo "rx-5500-xt"
            ;;
        "7340"|"7341")
            log "✓ 检测到：AMD Radeon RX 5700 XT"
            echo "rx-5700-xt"
            ;;
        "7342"|"7343")
            log "✓ 检测到：AMD Radeon RX 5700"
            echo "rx-5700"
            ;;
        "7344"|"7345")
            log "✓ 检测到：AMD Radeon RX 5600"
            echo "rx-5600"
            ;;

        # RDNA 2 (RX 6000 系列)
        "7320"|"7321"|"7322")
            log "✓ 检测到：AMD Radeon RX 6900 XT"
            echo "rx-6900-xt"
            ;;
        "7323"|"7324"|"7325")
            log "✓ 检测到：AMD Radeon RX 6800 XT"
            echo "rx-6800-xt"
            ;;
        "7326"|"7327")
            log "✓ 检测到：AMD Radeon RX 6800"
            echo "rx-6800"
            ;;
        "7328"|"7329"|"732a")
            log "✓ 检测到：AMD Radeon RX 6700 XT"
            echo "rx-6700-xt"
            ;;
        "732b"|"732c")
            log "✓ 检测到：AMD Radeon RX 6700"
            echo "rx-6700"
            ;;
        "732d"|"732e"|"732f")
            log "✓ 检测到：AMD Radeon RX 6600 XT"
            echo "rx-6600-xt"
            ;;
        "7330"|"7331")
            log "✓ 检测到：AMD Radeon RX 6600"
            echo "rx-6600"
            ;;
        "7332"|"7333")
            log "✓ 检测到：AMD Radeon RX 6500 XT"
            echo "rx-6500-xt"
            ;;
        "7334"|"7335")
            log "✓ 检测到：AMD Radeon RX 6400"
            echo "rx-6400"
            ;;

        *)
            log "⚠ 未知的 GPU Device ID: 1002:$gpu_id"
            echo "unknown-gpu"
            ;;
    esac
}

# 生成硬件配置文件
generate_hardware_config() {
    local cpu_model="$1"
    local gpu_model="$2"
    local host_name="nixos-${cpu_model}-${gpu_model}"
    
    log ""
    log "═══════════════════════════════════════════════════════"
    log "检测结果:"
    log "  CPU: $cpu_model"
    log "  GPU: $gpu_model"
    log "  主机名：$host_name"
    log "═══════════════════════════════════════════════════════"
    
    cat > "$OUTPUT_DIR/hardware-auto.nix" <<EOF
# 自动生成的硬件配置文件
# 由 detect-hardware.sh 脚本生成
# 生成时间：$(date '+%Y-%m-%d %H:%M:%S')

{ config, lib, pkgs, ... }:

{
  # 设置主机名（用于区分不同设备）
  networking.hostName = lib.mkDefault "$host_name";
  
  # 硬件型号标识（供其他模块使用）
  hardware.cpu.manualModel = lib.mkDefault "$cpu_model";
  hardware.gpu.manualModel = lib.mkDefault "$gpu_model";
}
EOF
    
    log "✓ 已生成硬件配置文件：$OUTPUT_DIR/hardware-auto.nix"
}

# 主程序
main() {
    log ""
    log "=== NixOS 硬件检测开始 ==="
    
    CPU_MODEL=$(detect_cpu)
    GPU_MODEL=$(detect_gpu)
    
    generate_hardware_config "$CPU_MODEL" "$GPU_MODEL"
    
    log "=== NixOS 硬件检测完成 ==="
    log ""
    log "下一步操作:"
    log "1. 检查生成的配置文件：cat $OUTPUT_DIR/hardware-auto.nix"
    log "2. 重新构建系统：sudo nixos-rebuild switch"
    log ""
}

main "$@"