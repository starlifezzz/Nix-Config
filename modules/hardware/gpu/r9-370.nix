# { config, lib, pkgs, ... }:

# {
#   config = lib.mkIf (config.hardware.gpu.manualModel == "r9-370") {
#     hardware.gpu.model = "r9-370";
    
#     services.xserver.videoDrivers = [ "modesetting" ];
    
#     boot.kernelParams = [
#       "amdgpu.runpm=0"
#       "pcie_aspm=off"
#     ];
    
#     hardware.graphics = {
#       enable = true;
#       enable32Bit = true;
      
#       extraPackages = with pkgs; [
#         libva
#         libvdpau
#       ];
#     };
    
#     environment.systemPackages = with pkgs; [ radeontop ];
#   };
# }

    { config, lib, pkgs, ... }:
    
    {
      config = lib.mkIf (config.hardware.gpu.manualModel == "r9-370") {
        hardware.gpu.model = "r9-370";
        
        # R9-370 使用 radeon 驱动（GCN 1.0-3.0）
        # Deleted:# services.xserver.videoDrivers = [ "radeon" ];  # 改为 radeon 驱动
        
        boot.kernelParams = [
          # Radeon 驱动电源管理
          "radeon.runpm=0"  # 禁用运行时 PM（老卡不稳定）
          "pcie_aspm=off"  # 关闭 ASPM
          
          # Radeon 特性
          "radeon.dpm=1"  # 启用动态电源管理
          "radeon.modeset=1"  # 启用内核模式设置
          
          # 性能优化
          "radeon.pcie_gen2=1"  # 强制启用 PCIe 2.0
          "radeon.benchmark=0"  # 禁用基准测试
        ];
        
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          
          extraPackages = with pkgs; [
            libva
            libvdpau
            
            # GCN 专属包
            mesa.opencl  # OpenCL 支持
            libva-vdpau-driver
            libvdpau-va-gl
          ];
        };
        
        environment.systemPackages = with pkgs; [
          radeontop  # GPU 监控
          # Deleted:corectrl  # R9-370 不支持 CoreCtrl
        ];
        
        # Xorg 加速优化
        services.xserver.videoDrivers = lib.mkAfter [ "radeon" ];
      };
    }