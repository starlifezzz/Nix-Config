# /etc/nixos/flake-hardware.nix
{
  description = "NixOS Hardware Configuration Switcher";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # 定义所有支持的硬件组合
      hardwareConfigs = {
        "1600x-r9370" = { cpu = "ryzen-1600x"; gpu = "r9-370"; };
        "2600-rx5500" = { cpu = "ryzen-2600"; gpu = "rx-5500"; };
        "2600-rx6600xt" = { cpu = "ryzen-2600"; gpu = "rx-6600-xt"; };
        "3600-rx6600xt" = { cpu = "ryzen-3600"; gpu = "rx-6600-xt"; };
      };
      
      # 生成配置的函数
      makeConfig = name: hw: 
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit (hw) cpu gpu;
            inherit self;
          };
          modules = [
            ./configuration.nix
            
            # 根据传入的 cpu/gpu 参数动态导入配置
            ({ config, lib, pkgs, ... }: {
              imports = 
                lib.optional (builtins.pathExists ./modules/hardware/cpu/${hw.cpu}.nix)
                  ./modules/hardware/cpu/${hw.cpu}.nix
                ++ lib.optional (builtins.pathExists ./modules/hardware/gpu/${hw.gpu}.nix)
                  ./modules/hardware/gpu/${hw.gpu}.nix;
              
              networking.hostName = "nixos-${name}";
            })
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs makeConfig hardwareConfigs;
    };
}