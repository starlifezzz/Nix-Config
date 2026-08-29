{ pkgs, ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.kernelParams = [
    # ✅ 移除 amdgpu.runpm=0 - Linux 7.0 中运行时电源管理已足够稳定

    # ═══════════════════════════════════════════════════════════
    # ✅ 禁用 MPO (Multi-Plane Overlay) — 修复 6600XT 桌面卡顿/闪烁
    # ═══════════════════════════════════════════════════════════
    # 原因: RDNA2 (Navi 23) 在 Linux 下 MPO 硬件合成路径有已知缺陷，
    #       导致桌面/滚动/窗口动画卡顿（COSMIC 与 KDE 均受影响，KDE 有
    #       软件规避所以感知弱，COSMIC 直接暴露）。
    # 依据: 内核文档 amdgpu(4) 的 disable_mpo 参数（官方），社区大量 6600XT
    #       用户实测禁用后桌面恢复流畅 (LTT forum #1486309 等)。
    # 效果: 桌面合成走纯 GPU 直接扫描输出，消除 MPO 抖动；游戏性能无感知损失。
    "amdgpu.disable_mpo=1"

    # # ✅ PCIe ASPM 节能模式（桌面用户推荐）
    # "pcie_aspm=powersupersave"

    # ✅ HDMI/DP 音频输出（GPU 专属配置，其他模块不应重复设置）
    "amdgpu.audio=1"

    "amdgpu.dc=1" # 启用 Display Core（必须）

    # ✅ Linux 7.0 新增：启用 GPU 错误报告和恢复机制
    "amdgpu.gpu_recovery=1"

    # Navi 23 特定优化 - 调整值以平衡性能和稳定性
    # "amdgpu.sched_hw_submission=128" # 用户待测：提升 0-5%（游戏负载高时），延迟略增

    # ═══════════════════════════════════════════════════════════
    # ✅ GPU 稳定性增强 - 解决 AMD RX 5500 图形环超时问题
    # ═══════════════════════════════════════════════════════════
    # "drm.gpu_recovery=1" # 启用DRM GPU恢复机制
    # "drm.debug=0" # 禁用DRM调试（减少日志开销）
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
      # mesa
      libva
      libvdpau-va-gl

      # ✅ 注意：AMDVLK 已废弃，改用 RADV（Mesa Vulkan，已包含在 mesa 中）
      # OBS 等应用会自动使用 VAAPI/VDPAU 进行硬件编码
    ];
  };

  boot.initrd.kernelModules = [ "amdgpu" ];

  # ✅ GPU 监控工具
  environment.systemPackages = with pkgs; [
    radeontop
    # lm_sensors 已在 CPU 模块中统一安装，避免重复
  ];
}
