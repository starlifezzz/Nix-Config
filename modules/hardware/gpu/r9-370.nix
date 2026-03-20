{ config, lib, pkgs, ... }:

{
  imports = [
    ./gpu-detect.nix
  ];
  
  config = lib.mkMerge [
    {
      hardware.gpu.model = "r9-370";
      
      # R9 370 (GCN 3.0) 驱动配置
      services.xserver.videoDrivers = [ "modesetting" ];
      
      boot.kernelParams = [
        "amdgpu.runpm=0"
        "pcie_aspm=off"
      ];
      
      # GCN 3.0 硬件加速
      hardware.opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = true;
        
        extraPackages = with pkgs; [
          rocmPackages.clr
          libva
          libvdpau
        ];
      };
      
      # VDPAU 支持（R9 370 更适合 VDPAU）
      nixpkgs.config.packageOverrides = pkgs: {
        vaapiDriver = pkgs.vaapiDriver.override {
          drivers = [ "r600" ];
        };
      };
      
      # 监控工具
      environment.systemPackages = with pkgs; [
        radeontop
      ];
    }
  ];
}