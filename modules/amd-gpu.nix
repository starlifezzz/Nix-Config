{ config, lib, pkgs, ... }:

{
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
    
    hardware.graphics = {
      enable = lib.mkDefault true;
      enable32Bit = lib.mkDefault true;
    };
    
    users.groups.video.members = lib.mkDefault [ ];
  };
}