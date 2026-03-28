# /etc/nixos/modules/hardware/detection.nix
{ config, lib, pkgs, ... }:

let
  supportedCPUs = [ "ryzen-1600x" "ryzen-2600" "ryzen-3600" ];
  supportedGPUs = [ "r9-370" "rx-5500" "rx-5500xt" "rx-5700" "rx-5700-xt" "rx-6600-xt" "rx-6600xt" ];
  
in
{
  options.hardware = {
    cpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedCPUs);
        default = null;
        description = "手动指定的 CPU 型号（必需通过 flake.nix 配置）";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        description = "当前系统的 CPU 型号（从 manualModel 读取）";
      };
    };
    
    gpu = {
      manualModel = lib.mkOption {
        type = lib.types.nullOr (lib.types.enum supportedGPUs);
        default = null;
        description = "手动指定的 GPU 型号（必需通过 flake.nix 配置）";
      };
      
      model = lib.mkOption {
        type = lib.types.str;
        description = "当前系统的 GPU 型号（从 manualModel 读取）";
      };
    };
  };
  
  config = {
    # ✅ 严格模式：必须手动指定 CPU/GPU，否则构建失败
    hardware.cpu.model = 
      if config.hardware.cpu.manualModel != null 
      then config.hardware.cpu.manualModel 
      else builtins.abort "❌ CPU model not specified! Please specify a CPU in flake.nix outputs: ${builtins.concatStringsSep ", " supportedCPUs}";
    
    hardware.gpu.model = 
      if config.hardware.gpu.manualModel != null 
      then config.hardware.gpu.manualModel 
      else builtins.abort "❌ GPU model not specified! Please specify a GPU in flake.nix outputs: ${builtins.concatStringsSep ", " supportedGPUs}";
  };
}
