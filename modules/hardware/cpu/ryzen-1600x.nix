{ config, lib, pkgs, ... }:

{
  config = lib.mkIf (config.hardware.cpu.manualModel == "ryzen-1600x") {
    hardware.cpu.model = "ryzen-1600x";
    
    boot.kernelParams = [
      "amd_pstate=active"
      "processor.max_cstate=5"
    ];
    
    powerManagement.powertop.enable = true;
    
    # Deleted: nix.settings.max-jobs = 6;
  };
}