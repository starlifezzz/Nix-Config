{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.cpu;
  
  # 检测 CPU 型号
  detectCpuModel = ''
    CPU_NAME=$(grep "model name" /proc/cpuinfo | head -n 1 | awk -F': ' '{print $2}')
    
    if echo "$CPU_NAME" | grep -q "Ryzen 5 1600X"; then
      echo "ryzen-1600x"
    elif echo "$CPU_NAME" | grep -q "Ryzen 5 2600"; then
      echo "ryzen-2600"
    else
      echo "unknown"
    fi
  '';
  
  detectedCpu = builtins.trim (builtins.readFile "${pkgs.runCommand "detect-cpu" {} ''
    ${cfg.detectScript}
  ''}");
  
in {
  options.hardware.cpu = {
    enable = lib.mkEnableOption "CPU specific optimizations";
    
    autoDetect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "自动检测并应用 CPU 配置";
    };
    
    model = lib.mkOption {
      type = lib.types.enum [ "ryzen-1600x" "ryzen-2600" "unknown" ];
      default = "unknown";
      description = "CPU 型号";
    };
    
    manualModel = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "ryzen-1600x" "ryzen-2600" ]);
      default = null;
      description = "手动指定 CPU 型号（如果自动检测失败）";
    };
    
    detectScript = lib.mkOption {
      type = lib.types.str;
      default = detectCpuModel;
      description = "CPU 检测脚本";
    };
  };
  
  config = lib.mkIf cfg.enable {
    hardware.cpu.model = if cfg.autoDetect then 
      (if cfg.manualModel != null then cfg.manualModel else detectedCpu)
    else 
      (cfg.manualModel or "unknown");
  };
}