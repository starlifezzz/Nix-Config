{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      hardware.gpu.model = lib.mkDefault "r9-370";
      
      services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
      
      boot.kernelParams = [
        "amdgpu.runpm=0"
        "pcie_aspm=off"
      ];
      
      hardware.opengl = {
        enable = lib.mkDefault true;
        driSupport = lib.mkDefault true;
        driSupport32Bit = lib.mkDefault true;
        
        extraPackages = with pkgs; [
          libva
          libvdpau
        ];
      };
      
      environment.systemPackages = with pkgs; [
        radeontop
      ];
    }
  ];
}