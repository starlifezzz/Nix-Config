{ config, lib, pkgs, ... }:

{
  imports = [
    ./cpu/cpu-detect.nix
    ./gpu/gpu-detect.nix
    ./cpu/ryzen-1600x.nix
    ./cpu/ryzen-2600.nix
    ./gpu/r9-370.nix
    ./gpu/rx-5500.nix
  ];
}