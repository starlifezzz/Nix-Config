{ config, lib, pkgs, ... }:

{
  config = lib.mkMerge [
    {
      hardware.cpu.model = lib.mkDefault "ryzen-1600x";
      
      boot.kernelParams = [
        "amd_pstate=active"
        "processor.max_cstate=5"
      ];
      
      powerManagement.powertop.enable = lib.mkDefault true;
      
      nix.settings.max-jobs = lib.mkDefault 6;
    }
  ];
}