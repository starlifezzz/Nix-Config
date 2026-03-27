{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.gpu.manualModel == "r9-370") {
    hardware.gpu.model = "r9-370";
    
    # ✅ 使用 amdgpu 驱动（更现代，支持更好）
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    # ✅ 修复死机问题 - Southern Islands 稳定设置
    boot.kernelParams = [
      # ⚠️ 关键修复：电源管理保守设置
      "amdgpu.runpm=0"                 # 禁用运行时 PM（避免死机）
      "amdgpu.dpm=1"                   # 动态电源管理
      "amdgpu.dc=0"                    # ⚠️ 禁用 Display Core（R9 370 不支持）
      
      # Southern Islands 支持
      "amdgpu.si_support=1"
      "radeon.si_support=0"
      
      # ⚠️ 禁用 ASPM 提高稳定性
      "pcie_aspm=off"
      
      # 性能优化
      "amdgpu.pcie_gen2=1"
    ];
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      
      extraPackages = with pkgs; [
        libva
        libvdpau
        mesa.opencl
        libva-vdpau-driver
        libvdpau-va-gl
      ];
    };
    
    # 在 initrd 阶段加载 amdgpu
    boot.initrd.kernelModules = [ "amdgpu" ];
    
    environment.systemPackages = with pkgs; [
      radeontop
    ];
  };
}