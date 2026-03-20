{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "rx-5500xt") {
    hardware.gpu.model = "rx-5500xt";
    
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    boot.kernelParams = [
      "amdgpu.runpm=1"
      "pcie_aspm=performance"
      "amdgpu.ppfeaturemask=0xffffffff"
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        libva
        libvdpau
        vulkan-loader
        vulkan-tools
      ];
    };
    
    environment.systemPackages = with pkgs; [ radeontop ];
  };
}