{ config, lib, pkgs, ... }:

let
  detectScript = pkgs.writeShellScriptBin "detect-hardware" ''
    #!/usr/bin/env bash
    set -euo pipefail
    
    OUTPUT_FILE="/etc/nixos/hardware-auto.nix"
    
    # CPU 检测
    if grep -q "AMD Ryzen 5 1600X" /proc/cpuinfo; then
      CPU_MODEL="ryzen-1600x"
    elif grep -q "AMD Ryzen 5 2600" /proc/cpuinfo; then
      CPU_MODEL="ryzen-2600"
    elif grep -q "AMD Ryzen 5 3600" /proc/cpuinfo; then
      CPU_MODEL="ryzen-3600"
    else
      CPU_MODEL="unknown-cpu"
    fi
    
    # GPU 检测
    GPU_MODEL="unknown-gpu"
    
    if command -v lspci &>/dev/null; then
      DEVICE_ID=$(lspci -nn | awk '/\[1002:[0-9a-fA-F]+\]/ && /VGA|Display/ {
        match($0, /\[1002:([0-9a-fA-F]+)\]/, arr)
        if (arr[1] != "") print tolower(arr[1])
      }' | head -1)
      
      if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID=$(lspci -nn | grep '\[1002:' | head -1 | sed 's/.*\[1002:\([0-9a-fA-F]*\).*/\1/' | tr '[:upper:]' '[:lower:]')
      fi
      
      if [ -n "$DEVICE_ID" ]; then
        case "$DEVICE_ID" in
          "7340"|"7341") GPU_MODEL="rx-5700-xt" ;;
          "7342"|"7343") GPU_MODEL="rx-5700" ;;
          "7344"|"7345") GPU_MODEL="rx-5600" ;;
          "7310"|"7311") GPU_MODEL="rx-5600-xt" ;;
          "731e"|"731f") GPU_MODEL="rx-5500-xt" ;;
          *) GPU_MODEL="unknown-gpu" ;;
        esac
      fi
    fi
    
    cat > "$OUTPUT_FILE" << EOF
# Auto-generated hardware configuration
# Generated at: $(date)
# DO NOT EDIT MANUALLY

{ config, lib, pkgs, ... }:

{
  hardware.cpu.manualModel = lib.mkDefault "$CPU_MODEL";
  hardware.gpu.manualModel = lib.mkDefault "$GPU_MODEL";
  
  networking.hostName = lib.mkDefault ("nixos-" + "$CPU_MODEL" + "-" + "$GPU_MODEL");
}
EOF
    
    echo "Hardware detected: CPU=$CPU_MODEL, GPU=$GPU_MODEL"
  '';
in

{
  systemd.services.hardware-detection = {
    description = "Detect hardware and generate configuration";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${detectScript}/bin/detect-hardware";
      RemainAfterExit = false;
    };
  };
  
  environment.systemPackages = [ detectScript ];
}