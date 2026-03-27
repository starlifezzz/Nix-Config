{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "rx-6600-xt") {
    hardware.gpu.model = "rx-6600-xt";
    
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    boot.kernelParams = [
      "amdgpu.runpm=0"
      "pcie_aspm=performance"
      "amdgpu.ppfeaturemask=0xffffffff"
      "amdgpu.dc=1"
      "amdgpu.sched_hw_submission=256"
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
        rocmPackages.clr.icd
        libva-vdpau-driver
        libvdpau-va-gl
        mesa
      ];
    };
    
    hardware.firmware = [ pkgs.linux-firmware ];
    hardware.enableRedistributableFirmware = true;
    
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    environment.systemPackages = with pkgs; [
      radeontop
      vkmark
    ];
  };
}