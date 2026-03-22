{ config, lib, pkgs, ... }:

{
  options.hardware.cpu = {
    manualModel = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "ryzen-1600x" "ryzen-2600" "ryzen-3600" "unknown-cpu" ]);
      default = null;
    };
    
    model = lib.mkOption {
      type = lib.types.str;
      description = "CPU 型号";
    };
  };
  
  config.hardware.cpu.model = 
    if config.hardware.cpu.manualModel != null 
    then config.hardware.cpu.manualModel 
    else "unknown";
}