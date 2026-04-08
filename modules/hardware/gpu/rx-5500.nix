{ config, lib, pkgs, ... }:

{
  # 启用 AMDGPU 驱动
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  # 内核参数优化 - Navi 14 (RX 5500)
  boot.kernelParams = [
    # GPU 电源管理
    "amdgpu.runpm=0"  # 禁用运行时电源管理（提高稳定性）
    
    # ✅ PCIe ASPM 节能模式（桌面用户推荐）
    "pcie_aspm=powersupersave"
    
    # ✅ HDMI/DP 音频输出（GPU 专属配置，CPU 模块不应重复设置）
    "amdgpu.audio=1"
    
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
      
      # ✅ OpenCL ICD loader（必需）
      ocl-icd
      
      # OpenCL 支持
      rocmPackages.clr.icd
      
      # ✅ 视频编解码加速
      mesa
      libva
      libvdpau-va-gl
      
      # ✅ AMF 头文件（用于 OBS 等编码加速）
      # 注意：AMDVLK 已废弃，改用 RADV（Mesa Vulkan，已包含在 mesa 中）
      # OBS 会自动使用 VAAPI/VDPAU 进行硬件编码
    ];
  };
  
  # 固件加载
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.enableRedistributableFirmware = true;
  
  # 在 initrd 阶段加载 AMDGPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  # ✅ GPU 监控工具
  environment.systemPackages = with pkgs; [
    radeontop
    # lm_sensors 已在 CPU 模块中安装，此处不再重复
  ];
}
