{ config, lib, pkgs, ... }:

let
  # 定义支持的硬件型号
  supportedCPUs = [ "ryzen-1600x" "ryzen-2600" "ryzen-3600" "unknown-cpu" ];
  supportedGPUs = [ "r9-370" "rx-5500" "rx-5500xt" "rx-5700" "rx-5700-xt" "rx-6600-xt" "unknown-gpu" ];
  
in
{
  options.hardware = {
    cpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedCPUs);
        default = null;
        description = "手动指定的 CPU 型号";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        description = "当前系统的 CPU 型号";
      };
    };
    
    gpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedGPUs);
        default = null;
        description = "手动指定的 GPU 型号";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        description = "当前系统的 GPU 型号";
      };
    };
  };
  
  config = {
    # 确定 CPU 型号：优先使用手动指定，否则使用自动检测
    hardware.cpu.model = 
      if config.hardware.cpu.manualModel != null 
      then config.hardware.cpu.manualModel 
      else "unknown";
    
    # 确定 GPU 型号：优先使用手动指定，否则使用自动检测
    hardware.gpu.model = 
      if config.hardware.gpu.manualModel != null 
      then config.hardware.gpu.manualModel 
      else "unknown";
    
    # 根据 CPU 型号动态设置主机名
    networking.hostName = lib.mkDefault (
      if config.hardware.cpu.model != "unknown" && config.hardware.gpu.model != "unknown"
      then "nixos-${config.hardware.cpu.model}-${config.hardware.gpu.model}"
      else "nixos"
    );
    
    # 启用硬件检测服务（仅在首次启动时运行）
    systemd.services.hardware-detect = {
      description = "Detect hardware and generate configuration on first boot";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = false;
        ExecStart = pkgs.writeShellScript "detect-hardware" ''
          #!/usr/bin/env bash
          set -euo pipefail
          
          OUTPUT="/etc/nixos/hardware-auto.nix"
          
          # 如果已存在且包含有效配置则跳过
          if [ -f "$OUTPUT" ] && grep -q "hardware.cpu.manualModel" "$OUTPUT"; then
            echo "Hardware configuration already exists, skipping detection"
            exit 0
          fi
          
          # CPU 检测
          CPU="unknown-cpu"
          if grep -q "AMD Ryzen 5 2600" /proc/cpuinfo; then
            CPU="ryzen-2600"
          elif grep -q "AMD Ryzen 5 1600X" /proc/cpuinfo; then
            CPU="ryzen-1600x"
          elif grep -q "AMD Ryzen 5 3600" /proc/cpuinfo; then
            CPU="ryzen-3600"
          fi
          
          # GPU 检测
          GPU="unknown-gpu"
          if command -v lspci &>/dev/null; then
            GPU_ID=$(lspci -nn | grep '\[1002:' | head -1 | sed 's/.*\[1002:\([0-9a-fA-F]*\).*/\1/' | tr '[:upper:]' '[:lower:]')
            case "$GPU_ID" in
              "66af"|"66b0"|"66b1") GPU="r9-370" ;;
              "731e"|"731f") GPU="rx-5500-xt" ;;
              "7340"|"7341") GPU="rx-5700-xt" ;;
              "7342"|"7343") GPU="rx-5700" ;;
              "732d"|"732e"|"732f") GPU="rx-6600-xt" ;;
            esac
          fi
          
          # 生成配置
          cat > "$OUTPUT" << EOF
{ config, lib, pkgs, ... }:

{
  networking.hostName = lib.mkDefault "nixos-\${CPU}-\${GPU}";
  hardware.cpu.manualModel = lib.mkDefault "${CPU}";
  hardware.gpu.manualModel = lib.mkDefault "${GPU}";
}
EOF
          
          echo "Generated hardware configuration for CPU=${CPU}, GPU=${GPU}"
        '';
      };
    };
  };
}