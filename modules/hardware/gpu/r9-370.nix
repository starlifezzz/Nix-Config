{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "r9-370") {
    hardware.gpu.model = "r9-370";
    
    # R9-370 使用 radeon 驱动（GCN 1.0-3.0）
    services.xserver.videoDrivers = [ "radeon" ];
    
    boot.kernelParams = [
      # Radeon 驱动电源管理
      "radeon.runpm=0"
      "pcie_aspm=off"
      
      # Radeon 特性
      "radeon.dpm=1"
      "radeon.modeset=1"
      
      # 性能优化
      "radeon.pcie_gen2=1"
      "radeon.benchmark=0"
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        libva
        libvdpau
        mesa.opencl
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    
    environment.systemPackages = with pkgs; [
      radeontop
    ];
  };
}