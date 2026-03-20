{ config, lib, pkgs, ... }:

{

    # modules/amd-gpu.nix 应改为：
  imports = [
    ./hardware/cpu/cpu-detect.nix
    ./hardware/gpu/gpu-detect.nix
  ];
  
  config = {
    services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" "radeon" ];
    
    boot.kernelParams = [
      "iommu=soft"
    ];
    
    hardware.firmware = with pkgs; [
      linux-firmware
    ];
    
    hardware.opengl = {
      enable = lib.mkDefault true;
      driSupport = lib.mkDefault true;
      driSupport32Bit = lib.mkDefault true;
    };
    
    sound.enable = lib.mkDefault true;
    
    users.groups.video.members = lib.mkDefault [ ];
  };
}