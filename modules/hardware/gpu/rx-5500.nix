{ config, lib, pkgs, ... }:

{
  # 启用 AMDGPU 驱动
  services.xserver.videoDrivers = [ "amdgpu" ];
  
  # 内核参数优化 - Navi 14 (RX 5500) - Linux 7.0 兼容版本
  boot.kernelParams = [
    # AMDGPU 特性 - Linux 7.0 推荐配置
    "amdgpu.dc=1"  # 启用 Display Core（必须）

    # Linux 7.0 新增：启用 GPU 错误报告和恢复机制
    "amdgpu.gpu_recovery=1"

    # 添加稳定性参数（infoframe问题必需）
    "amdgpu.sg_display=0"      # 禁用SG display以避免infoframe问题

    # 可选优化参数（对性能无负面影响）
    "amdgpu.sched_hw_submission=16"  # 提高硬件提交队列数量
    "amdgpu.lockup_timeout=10000"    # 增加GPU锁死超时时间
    
    # ✅ 移除 amdgpu.gpu_reset 参数（Linux 7.0+ 已废弃，由 gpu_recovery 替代）
    "amdgpu.aspm=0"                  # 禁用PCIe ASPM节能模式（提高稳定性）
    "amdgpu.dpm=1"                   # 启用动态电源管理（保持启用以平衡性能和功耗）
    "amdgpu.deep_color=0"            # 禁用深色模式（减少HDMI兼容性问题）
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
  
  # 在 initrd 阶段加载 AMDGPU
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  # ✅ GPU 监控工具
  environment.systemPackages = with pkgs; [
    radeontop
    # lm_sensors 已在 CPU 模块中安装，此处不再重复
  ];
}