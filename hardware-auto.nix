# Auto-generated hardware configuration
# Generated at: 2026年 03月 22日 星期日 14:45:24 CST
# DO NOT EDIT MANUALLY

{ config, lib, pkgs, ... }:

{
  hardware.cpu.manualModel = lib.mkDefault "ryzen-2600";
  hardware.gpu.manualModel = lib.mkDefault "unknown-gpu";
  
  networking.hostName = lib.mkDefault ("nixos-" + "ryzen-2600" + "-" + "unknown-gpu");
}
