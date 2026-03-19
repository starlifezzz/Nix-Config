{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # AMD R9 370 (CIK) GPU 配置 - 使用 amdgpu 驱动
  # ═══════════════════════════════════════════════════════════
  
  # 启用 AMD GPU 固件
  hardware.enableRedistributableFirmware = true;
  
  # 禁止加载 radeon 驱动（避免与 amdgpu 冲突）
  boot.blacklistedKernelModules = [ "radeon" ];
  
  # 内核参数优化
  boot.kernelParams = [
    # R9 370 (Tonga/GCN 1.2) 强制使用 amdgpu 驱动
    "radeon.cik_support=0"     # 禁用 radeon 对 CIK/GCN 的支持
    "amdgpu.cik_support=1"     # 强制 amdgpu 接管
    "amdgpu.runpm=0"           # 禁用运行时电源管理（防止黑屏）
  ];
}