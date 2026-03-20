{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.cpu;
  
in {
  options.hardware.cpu = {
    enable = lib.mkEnableOption "CPU specific optimizations";
    
    autoDetect = lib.mkOption {
      type = lib.types.bool;
      default = false;
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
  };
  
  config = lib.mkIf cfg.enable {
    hardware.cpu.model = lib.mkDefault (
      if cfg.manualModel != null then cfg.manualModel else "unknown"
    );
  };
}