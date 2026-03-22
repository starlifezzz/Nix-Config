{ config, lib, pkgs, ... }:

{
  options.hardware.gpu = {
    manualModel = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "r9-370" "rx-5500" "rx-5500xt" "rx-5700" "rx-5700-xt" "unknown-gpu" ]);
      default = null;
    };
    
    model = lib.mkOption {
      type = lib.types.str;
      description = "GPU 型号";
    };
  };
  
  config.hardware.gpu.model = 
    if config.hardware.gpu.manualModel != null 
    then config.hardware.gpu.manualModel 
    else "unknown";
}