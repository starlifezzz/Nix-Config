# { config, lib, pkgs, ... }:

# {
#   imports = [
#     ./hardware/cpu/cpu-detect.nix
#     ./hardware/gpu/gpu-detect.nix
#   ];
  
#   config = {
#     # 根据 GPU 型号自动设置正确的驱动
#     services.xserver.videoDrivers = lib.mkIf (
#       config.hardware.gpu.manualModel != null
#     ) (if config.hardware.gpu.manualModel == "r9-370" 
#        then [ "modesetting" ]
#        else if config.hardware.gpu.manualModel == "rx-5500xt"
#        then [ "amdgpu" ]
#        else [ "amdgpu" ]);  # 默认
    
#     boot.kernelParams = [
#       "iommu=pt"  # 使用 passthrough 模式，性能更好
#     ];
    
#     hardware.firmware = with pkgs; [
#       linux-firmware
#     ];
    
#     hardware.graphics = {
#       enable = lib.mkDefault true;
#       enable32Bit = lib.mkDefault true;
#     };
    
#     users.groups.video.members = lib.mkDefault [ ];
#   };
# }
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