{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      hardware.gpu.model = lib.mkDefault "rx-5500xt";
      
      services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" ];
      
      boot.kernelParams = [
        "amdgpu.runpm=1"
        "pcie_aspm=performance"
        "amdgpu.ppfeaturemask=0xffffffff"
      ];
      
      hardware.opengl = {
        enable = lib.mkDefault true;
        driSupport = lib.mkDefault true;
        driSupport32Bit = lib.mkDefault true;
        
        extraPackages = with pkgs; [
          libva
          libvdpau
          vulkan-loader
          vulkan-tools
        ];
      };
      
      hardware.vulkan.enable = lib.mkDefault true;
      
      environment.systemPackages = with pkgs; [
        radeontop
      ];
    }
  ];
}