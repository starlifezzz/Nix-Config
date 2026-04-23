{ config, lib, pkgs, ... }:

{
  # 启用 AMDGPU 驱动
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  # 内核参数优化 - Navi 14 (RX 5500) - Linux 7.0 兼容版本
  boot.kernelParams = [
    # ✅ 移除 amdgpu.runpm=0 - Linux 7.0 中运行时电源管理已足够稳定
    # GPU 电源管理由内核自动处理
    
    # ✅ PCIe ASPM 节能模式（桌面用户推荐）
    "pcie_aspm=powersupersave"
    
    # ✅ HDMI/DP 音频输出（GPU 专属配置，CPU 模块不应重复设置）
    "amdgpu.audio=1"
    
    # AMDGPU 特性 - Linux 7.0 推荐配置
    "amdgpu.dc=1"  # 启用 Display Core（必须）
    
    # ✅ Linux 7.0 新增：启用 GPU 错误报告和恢复机制
    "amdgpu.gpu_recovery=1"
    
    # Navi 14 特定优化 - 调整值以提高稳定性
    "amdgpu.sched_hw_submission=32"  # 进一步降低到32以减少Fence超时问题
    
    # ✅ 添加稳定性参数
    "amdgpu.vm_update_mode=3"  # 使用同步更新模式提高稳定性
    "amdgpu.sg_display=0"      # 禁用SG display以避免infoframe问题
    
    # ✅ 添加额外的稳定性参数
    "amdgpu.lockup_timeout=10000"  # 增加GPU锁死超时时间
    # 移除无效参数: amdgpu.gpu_sched_enable=1 (当前内核不支持)
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