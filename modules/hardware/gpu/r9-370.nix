{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "r9-370") {
    hardware.gpu.model = "r9-370";
    
    services.xserver.videoDrivers = [ "modesetting" ];
    
    boot.kernelParams = [
      "amdgpu.runpm=0"
      "pcie_aspm=off"
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        libva
        libvdpau
      ];
    };
    
    environment.systemPackages = with pkgs; [ radeontop ];
  };
}