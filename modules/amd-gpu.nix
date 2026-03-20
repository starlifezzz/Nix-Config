{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware/cpu-detect.nix
    ./hardware/cpu/ryzen-1600x.nix
    ./hardware/cpu/ryzen-2600.nix
    ./hardware/gpu/gpu-detect.nix
    ./hardware/gpu/r9-370.nix
    ./hardware/gpu/rx-5500xt.nix
  ];
  
  config = {
    # 启用 AMD GPU 基础驱动
    services.xserver.videoDrivers = lib.mkDefault [ "amdgpu" "radeon" ];
    
    # IOMMU 设置
    boot.kernelParams = [
      "iommu=soft"
    ];
    
    # 固件
    hardware.firmware = with pkgs; [
      linux-firmware
    ];
    
    # 硬件加速通用设置
    hardware.opengl = {
      enable = lib.mkDefault true;
    };
    
    # 音频支持（HDMI/DP）
    sound.enable = lib.mkDefault true;
    
    # 用户组
    users.groups.video.members = lib.mkDefault [ ];
  };
}