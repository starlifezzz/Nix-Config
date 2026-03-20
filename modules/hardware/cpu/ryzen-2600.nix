
{ config, lib, pkgs, ... }:

{
  imports = [
    ../cpu-detect.nix
  ];
  
  config = lib.mkMerge [
    {
      hardware.cpu.model = "ryzen-2600";
      
      # Zen+ 架构优化
      boot.kernelParams = [
        "amd_pstate=active"
        "processor.max_cstate=5"
        "sched_energy_aware=0"
      ];
      
      # Zen+ 改进的电源管理
      services.udev.extraRules = ''
        # Ryzen 2600 特定优化
        ACTION=="add", SUBSYSTEM=="pci", KERNEL=="0000:00:00.0", ATTR{power/control}="on"
      '';
      
      # 性能模式
      powerManagement.powertop.enable = true;
      
      # 编译优化
      nix.settings.max-jobs = 12;  # 6 核心 12 线程
    }
  ];
}