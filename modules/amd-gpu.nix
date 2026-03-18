{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # AMD R9 370 (CIK) GPU 配置 - 使用 radeon 驱动
  # ═══════════════════════════════════════════════════════════
  
  # 内核参数优化
  boot.kernelParams = [
    # Radeon 驱动核心参数
    "radeon.cik_support=1"       # 启用 CIK 支持（R9 370）
    "amdgpu.cik_support=0"       # 禁用 amdgpu CIK 支持（避免冲突）
    "radeon.si_support=1"        # 启用 Sea Islands 支持
    "radeon.modeset=1"           # 启用 KMS（必须）
    
    # DPM (动态电源管理)
    "radeon.dpm=1"               # 启用 DPM
    "radeon.dpm.force_performance_level=high"  # 高性能模式
    
    # 音频和电源
    "radeon.audio=1"             # HDMI/DP 音频
    "radeon.aspm=0"              # 禁用 ASPM（提高稳定性）
    "pcie_aspm=off"              # 关闭 PCIe ASPM
    
    # 视频内存
    "radeon.vram_limit=0"        # 不限制显存使用
  ];

  # 强制加载 radeon 模块，阻止 amdgpu
  boot.kernelModules = [ "radeon" ];
  boot.blacklistedKernelModules = [ "amdgpu" ];

  # 确保固件已加载
  hardware.firmware = with pkgs; [
    linux-firmware
  ];

  # OpenGL/Vulkan 支持
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      mesa
      mesa.drivers
      libvdpau-va-gl
      vaapiVdpau
      vulkan-loader
    ];
    extraPackages32 = with pkgs; [
      driversi686Linux.mesa
      driversi686Linux.mesa.drivers
    ];
  };

  # 环境变量配置
  environment.variables = {
    # 强制使用 radeonsi 驱动
    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
    
    # VDPAU 配置
    VDPAU_DRIVER = "r600";
    
    # VA-API 配置
    LIBVA_DRIVER_NAME = "r600";
  };

  # 用户组配置
  users.users.zhangchongjie.extraGroups = [ "video" "render" "input" ];

  # 系统服务优化
  systemd.services."gpu-power-management" = {
    description = "AMD GPU Power Management Optimization";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/sh -c '${pkgs.coreutils}/bin/chmod 644 /sys/class/drm/card0/device/power_dpm_state'";
      RemainAfterExit = true;
    };
  };

  # udev 规则 - 设置 GPU 权限
  services.udev.extraRules = ''
    # AMD GPU 权限
    KERNEL=="renderD*", GROUP="render", MODE="0666"
    KERNEL=="card*", GROUP="video", MODE="0666"
    
    # 电源管理权限
    ATTR{drm/card0/device/power_dpm_state}="performance"
    ATTR{drm/card0/device/power_profile_method}="auto"
  '';

  # 性能优化提示
  powerManagement.cpuFreqGovernor = "ondemand";
}