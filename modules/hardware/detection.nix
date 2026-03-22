# /etc/nixos/modules/hardware/detection.nix
{ config, lib, pkgs, ... }:

let
  supportedCPUs = [ "ryzen-1600x" "ryzen-2600" "ryzen-3600" "unknown-cpu" ];
  supportedGPUs = [ "r9-370" "rx-5500" "rx-5500xt" "rx-5700" "rx-5700-xt" "rx-6600-xt" "unknown-gpu" ];
  
in
{
  options.hardware = {
    cpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedCPUs);
        default = null;
        description = "手动指定的 CPU 型号（可选）";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        default = "unknown";
        description = "当前系统的 CPU 型号";
      };
    };
    
    gpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedGPUs);
        default = null;
        description = "手动指定的 GPU 型号（可选）";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        default = "unknown";
        description = "当前系统的 GPU 型号";
      };
    };
  };
  
  config = {
    # 如果手动指定了型号则使用，否则保持默认值
    hardware.cpu.model = 
      if config.hardware.cpu.manualModel != null 
      then config.hardware.cpu.manualModel 
      else config.hardware.cpu.model;
    
    hardware.gpu.model = 
      if config.hardware.gpu.manualModel != null 
      then config.hardware.gpu.manualModel 
      else config.hardware.gpu.model;
  };
}