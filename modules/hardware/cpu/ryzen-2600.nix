{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      hardware.cpu.model = lib.mkDefault "ryzen-2600";
      
      boot.kernelParams = [
        "amd_pstate=active"
        "processor.max_cstate=5"
        "sched_energy_aware=0"
      ];
      
      powerManagement.powertop.enable = lib.mkDefault true;
      
      nix.settings.max-jobs = lib.mkDefault 12;
    }
  ];
}