{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.gpu;
  
  # 检测 GPU 型号
  detectGpuModel = ''
    GPU_ID=$(lspci -nn | grep -i "vga.*amd\|vga.*ati" | head -n 1 | awk '{print $NF}' | tr -d '[]')
    
    case "$GPU_ID" in
      *687F*) echo "r9-370" ;;        # R9 370 (Tonga)
      *731F*) echo "rx-5500xt" ;;     # RX 5500 XT (Navi 14)
      *) echo "unknown" ;;
    esac
  '';
  
in {
  options.hardware.gpu = {
    enable = lib.mkEnableOption "GPU specific configurations";
    
    autoDetect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "自动检测并应用 GPU 配置";
    };
    
    model = lib.mkOption {
      type = lib.types.enum [ "r9-370" "rx-5500xt" "unknown" ];
      default = "unknown";
      description = "GPU 型号";
    };
    
    manualModel = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "r9-370" "rx-5500xt" ]);
      default = null;
      description = "手动指定 GPU 型号";
    };
  };
  
  config = lib.mkIf cfg.enable {
    hardware.gpu.model = if cfg.autoDetect then
      (if cfg.manualModel != null then cfg.manualModel else "placeholder")
    else
      (cfg.manualModel or "unknown");
  };
}