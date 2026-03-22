{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "rx-5500") {
    hardware.gpu.model = "rx-5500";
    
    # 启用 AMDGPU 驱动
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    # 内核参数优化 - Navi 14 (RX 5500)
    boot.kernelParams = [
      # GPU 电源管理
      "amdgpu.runpm=0"  # 禁用运行时电源管理（提高稳定性）
      "pcie_aspm=performance"  # PCIe ASPM 性能模式
      
      # AMDGPU 特性
      "amdgpu.ppfeaturemask=0xffffffff"  # 启用所有电源管理特性
      "amdgpu.dc=1"  # 启用 Display Core（必须）
      
      # Navi 14 特定优化
      "amdgpu.sched_hw_submission=256"
    ];
    
    # 图形加速支持
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        # Vulkan 支持
        vulkan-loader
        vulkan-tools
        
        # OpenCL 支持
        rocmPackages.clr.icd
        
        # 视频编解码加速
        libva-vdpau-driver
        libvdpau-va-gl
        mesa.drivers
      ];
    };
    
    # 固件加载
    hardware.firmware = [ pkgs.linux-firmware ];
    hardware.enableRedistributableFirmware = true;
    
    # 在 initrd 阶段加载 AMDGPU
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    # 工具软件
    environment.systemPackages = with pkgs; [
      radeontop
      vkmark
    ];
  };
}