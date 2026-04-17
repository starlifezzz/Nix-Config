{ config, lib, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  boot.kernelParams = [
    # ✅ 移除 amdgpu.runpm=0 - Linux 7.0 中运行时电源管理已足够稳定
    
    # ✅ PCIe ASPM 节能模式（桌面用户推荐）
    "pcie_aspm=powersupersave"
    
    # ✅ HDMI/DP 音频输出（GPU 专属配置，其他模块不应重复设置）
    "amdgpu.audio=1"
    
    "amdgpu.dc=1"  # 启用 Display Core（必须）
    
    # ✅ Linux 7.0 新增：启用 GPU 错误报告和恢复机制
    "amdgpu.gpu_recovery=1"
    
    # Navi 23 特定优化 - 调整值以平衡性能和稳定性
    "amdgpu.sched_hw_submission=128"
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
  
  # ✅ GPU 监控工具
  environment.systemPackages = with pkgs; [
    radeontop
    # lm_sensors 已在 CPU 模块中统一安装，避免重复
  ];
}