{ config, lib, pkgs, ... }:

{
  imports = [
    ./gpu-detect.nix
  ];
  
  config = lib.mkMerge [
    {
      hardware.gpu.model = "rx-5500xt";
      
      # RX 5500XT (RDNA 1) 驱动配置
      services.xserver.videoDrivers = [ "amdgpu" ];
      
      boot.kernelParams = [
        "amdgpu.runpm=1"
        "pcie_aspm=performance"
        "amdgpu.ppfeaturemask=0xffffffff"
      ];
      
      # RDNA 硬件加速
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        
        extraPackages = with pkgs; [
          rocmPackages.clr
          libva
          libvdpau
          vulkan-loader
          vulkan-tools
        ];
      };
      
      # VA-API 支持（RX 5500XT 有更好的 VA-API 支持）
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiDriver = pkgs.vaapiDriver.override {
          drivers = [ "radeonsi" ];
        };
      };
      
      # Vulkan 支持
      hardware.vulkan.enable = true;
      
      # 监控工具
      environment.systemPackages = with pkgs; [
        radeontop
        vkmark
      ];
    }
  ];
}