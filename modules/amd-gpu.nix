{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware/cpu/cpu-detect.nix
    ./hardware/gpu/gpu-detect.nix
  ];
  
  config = {
    boot.kernelParams = [
      "iommu=soft""iommu=soft"  # 使用 passthrough 模式，性能更好
    ];
    
    hardware.firmware = with pkgs; [
      linux-firmware
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    
    users.groups.video.members = [ ];
  };
}