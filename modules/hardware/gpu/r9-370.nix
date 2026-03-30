{ config, lib, pkgs, ... }:

{
  # ✅ 使用 amdgpu 驱动（更现代，支持更好）
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  # ✅ 优化配置：尝试启用 DC 与音频支持
  boot.kernelParams = [
    # ⚠️ 关键修复：电源管理保守设置
    "amdgpu.runpm=0"                 # 禁用运行时 PM（避免死机）
    "amdgpu.dpm=1"                   # 动态电源管理
    
    # ✅ 尝试启用 Display Core（测试兼容性）
    # 如果遇到黑屏/花屏，请改回 dc=0
    "amdgpu.dc=1"
    
    # ✅ 新增：HDMI/DP 音频输出
    "amdgpu.audio=1"
    
    # ✅ 新增：PCIe ASPM 节能模式
    "pcie_aspm=powersupersave"
    
    # Southern Islands 支持
    "amdgpu.si_support=1"
    "radeon.si_support=0"
    
    # 性能优化
    "amdgpu.pcie_gen2=1"
    
    # ✅ 可选：如果 dc=1 有问题，可以添加调试参数
    # "amdgpu.dcdebug=0x10"
  ];
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    
    extraPackages = with pkgs; [
      # ✅ 新增：OpenCL ICD loader
      ocl-icd
      
      libva
      libvdpau
      mesa.opencl
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };
  
  # 在 initrd 阶段加载 amdgpu
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.enableRedistributableFirmware = true;

  environment.systemPackages = with pkgs; [
    radeontop
    lm_sensors
  ];
}