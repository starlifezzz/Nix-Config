{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.gpu;
  
in {
  options.hardware.gpu = {
    enable = lib.mkEnableOption "GPU specific configurations";
    
    autoDetect = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
    hardware.gpu.model = lib.mkDefault (
      if cfg.manualModel != null then cfg.manualModel else "unknown"
    );
  };
}