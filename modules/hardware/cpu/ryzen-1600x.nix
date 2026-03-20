{ config, lib, pkgs, ... }:

{
  imports = [
    ../cpu-detect.nix
  ];
  
  config = lib.mkMerge [
    {
      hardware.cpu.model = "ryzen-1600x";
      
      # Zen 架构优化
      boot.kernelParams = [
        "amd_pstate=active"
        "processor.max_cstate=5"
        "idle=poll"
      ];
      
      # CPU 频率调节
      services.udev.extraRules = ''
        # Ryzen 1600X 特定优化
        ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:00.0", ATTR{power/control}="on"
      '';
      
      # 性能模式
      powerManagement.powertop.enable = true;
      
      # 编译优化
      nix.settings.max-jobs = 6;  # 6 核心
    }
  ];
}