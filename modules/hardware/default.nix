{ config, lib, pkgs, ... }:

{
  imports = [
    ./cpu-detect.nix
    ./cpu/ryzen-1600x.nix
    ./cpu/ryzen-2600.nix
    ./gpu/gpu-detect.nix
    ./gpu/r9-370.nix
    ./gpu/rx-5500xt.nix
  ];
  
  config = {
    # 自动加载检测到的硬件配置
    assertions = [
      {
        assertion = config.hardware.cpu.model != "unknown" || config.hardware.cpu.manualModel != null;
        message = "无法检测到 CPU 型号，请手动设置 hardware.cpu.manualModel";
      }
      {
        assertion = config.hardware.gpu.model != "unknown" || config.hardware.gpu.manualModel != null;
        message = "无法检测到 GPU 型号，请手动设置 hardware.gpu.manualModel";
      }
    ];
    
    # 显示硬件信息
    system.activationScripts.hardware-info.text = ''
      echo "=== Hardware Configuration ==="
      echo "CPU Model: ${config.hardware.cpu.model}"
      echo "GPU Model: ${config.hardware.gpu.model}"
      echo "=============================="
    '';
  };
}