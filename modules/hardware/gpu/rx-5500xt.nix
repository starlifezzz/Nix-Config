# { config, lib, pkgs, ... }:

# {
#   config = lib.mkIf (config.hardware.gpu.manualModel == "rx-5500xt") {
#     hardware.gpu.model = "rx-5500xt";
    
#     services.xserver.videoDrivers = [ "amdgpu" ];
    
#     boot.kernelParams = [
#       "amdgpu.runpm=1"
#       "pcie_aspm=performance"
#       "amdgpu.ppfeaturemask=0xffffffff"
#     ];
    
#     hardware.graphics = {
#       enable = true;
#       enable32Bit = true;
      
#       extraPackages = with pkgs; [
#         libva
#         libvdpau
#         vulkan-loader
#         vulkan-tools
#       ];
#     };
    
#     environment.systemPackages = with pkgs; [ radeontop ];
#   };
# }
{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "rx-5500xt") {
    hardware.gpu.model = "rx-5500xt";
    
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    boot.kernelParams = [
      # GPU 电源管理
      "amdgpu.runpm=1"  # 运行时电源管理
      "pcie_aspm=performance"  # PCIe 性能模式
      
      # AMDGPU 特性启用
      "amdgpu.ppfeaturemask=0xffffffff"  # 启用所有电源管理特性
      "amdgpu.dc=1"  # 启用 Display Core（必须）
      "amdgpu.mes=1"  # 启用 MES（新内核需要）
      
      # 性能优化
      "amdgpu.sched_hw_submission=256"  # 增加硬件提交队列
      "amdgpu.vm_update_mode=3"  # 优化虚拟内存更新
    ];
    
hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        libva
        libvdpau
        vulkan-loader
        vulkan-tools
        
        # RDNA 专属优化包
        mesa.opencl  # OpenCL 支持
        libva-vdpau-driver  # VAAPI 转 VDPAU
        libvdpau-va-gl  # VDPAU 转 VAAPI
      ];
    };
    
    environment.systemPackages = with pkgs; [
      radeontop  # GPU 监控
      corectrl  # AMD GPU 超频和控制工具
    ];
    
    # 启用 FSR（FidelityFX Super Resolution）
    hardware.amdgpu = {
      initrd.enable = true;
      opencl.enable = true;
    };
  };
}