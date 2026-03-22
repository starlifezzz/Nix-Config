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
    
    # GPU 检测 - 完整版
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
          # RDNA 4 (RX 9000 系列)
          "7600"|"7601"|"7602"|"7603"|"7604") GPU_MODEL="rx-9070-xt" ;;
          "7605"|"7606"|"7607") GPU_MODEL="rx-9070" ;;
          "7608"|"7609") GPU_MODEL="rx-9060-xt" ;;
          
          # RDNA 3 (RX 7000 系列)
          "7300"|"7301"|"7302"|"7303"|"7304") GPU_MODEL="rx-7900-xtx" ;;
          "7305"|"7306"|"7307") GPU_MODEL="rx-7900-xt" ;;
          "7308"|"7309"|"730a"|"730b") GPU_MODEL="rx-7800-xt" ;;
          "730c"|"730d"|"730e") GPU_MODEL="rx-7700-xt" ;;
          "730f"|"7310"|"7311") GPU_MODEL="rx-7600" ;;
          
          # RDNA 2 (RX 6000 系列)
          "7320"|"7321"|"7322") GPU_MODEL="rx-6900-xt" ;;
          "7323"|"7324"|"7325") GPU_MODEL="rx-6800-xt" ;;
          "7326"|"7327") GPU_MODEL="rx-6800" ;;
          "7328"|"7329"|"732a") GPU_MODEL="rx-6700-xt" ;;
          "732b"|"732c") GPU_MODEL="rx-6700" ;;
          "732d"|"732e"|"732f") GPU_MODEL="rx-6600-xt" ;;
          "7330"|"7331") GPU_MODEL="rx-6600" ;;
          "7332"|"7333") GPU_MODEL="rx-6500-xt" ;;
          "7334"|"7335") GPU_MODEL="rx-6400" ;;
          
          # RDNA 1 (RX 5000 系列) - 您的显卡在这里
          "7310"|"7311") GPU_MODEL="rx-5600-xt" ;;
          "731e"|"731f") GPU_MODEL="rx-5500-xt" ;;
          "7340"|"7341") GPU_MODEL="rx-5700-xt" ;;
          "7342"|"7343") GPU_MODEL="rx-5700" ;;
          "7344"|"7345") GPU_MODEL="rx-5600" ;;
          
          # Polaris (RX 400/500 系列)
          "66af"|"66b0"|"66b1") GPU_MODEL="r9-370" ;;
          "67df"|"67ef") GPU_MODEL="rx-470" ;;
          "67e0"|"67e1") GPU_MODEL="rx-480" ;;
          "67ff") GPU_MODEL="rx-570" ;;
          "67df") GPU_MODEL="rx-580" ;;
          
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