{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  boot.kernelParams = [
    "amdgpu.runpm=0"
    
    # ✅ PCIe ASPM 节能模式（桌面用户推荐）
    "pcie_aspm=powersupersave"
    
    # ✅ HDMI/DP 音频输出
    "amdgpu.audio=1"
    
    "amdgpu.ppfeaturemask=0xffffffff"
    "amdgpu.dc=1"
    "amdgpu.sched_hw_submission=256"
  ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    
    extraPackages = with pkgs; [
      # Vulkan 支持
      vulkan-loader
      vulkan-tools
      
      # ✅ OpenCL ICD loader（必需）
      ocl-icd
      
      # OpenCL 支持
      rocmPackages.clr.icd
      
      # ✅ 视频编解码加速
      mesa
      libva
      libvdpau-va-gl
      
      # ✅ 注意：AMDVLK 已废弃，改用 RADV（Mesa Vulkan，已包含在 mesa 中）
      # OBS 等应用会自动使用 VAAPI/VDPAU 进行硬件编码
    ];
  };
  
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.enableRedistributableFirmware = true;
  
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  environment.systemPackages = with pkgs; [
    radeontop
    lm_sensors  # ✅ 传感器读取工具
  ];
}