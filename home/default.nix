# /etc/nixos/home/default.nix
{ config, pkgs, lib, ... }:

{
  imports = [
    ./home.nix
    ./kde.nix
  ];
}