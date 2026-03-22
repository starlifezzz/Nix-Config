{
  description = "NixOS configuration with flexible hardware selection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }:
    let
      # 定义所有支持的硬件组合
      hardwareConfigs = {
        # 默认配置（当前设备）
        "nixos" = { cpu = "ryzen-2600"; gpu = "rx-5500"; hostName = "nixos-2600-rx5500"; };
        
        # 其他硬件配置
        "nixos-1600x-r9370" = { cpu = "ryzen-1600x"; gpu = "r9-370"; hostName = "nixos-1600x-r9370"; };
        "nixos-2600-rx6600xt" = { cpu = "ryzen-2600"; gpu = "rx-6600-xt"; hostName = "nixos-2600-rx6600xt"; };
        "nixos-3600-rx6600xt" = { cpu = "ryzen-3600"; gpu = "rx-6600-xt"; hostName = "nixos-3600-rx6600xt"; };
      };
      
      makeConfig = name: hw: 
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          
          specialArgs = {
            inherit (hw) cpu gpu;
            inherit self;
          };
          
          modules = [
            ./configuration.nix
            
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc-ssd
            
            # 动态导入硬件特定配置
            ({ config, lib, pkgs, ... }: {
              imports = 
                lib.optional (builtins.pathExists ./modules/hardware/cpu/${hw.cpu}.nix)
                  ./modules/hardware/cpu/${hw.cpu}.nix
                ++ lib.optional (builtins.pathExists ./modules/hardware/gpu/${hw.gpu}.nix)
                  ./modules/hardware/gpu/${hw.gpu}.nix;
              
              networking.hostName = lib.mkDefault hw.hostName;
            })
            
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zhangchongjie = import ./home;
              home-manager.extraSpecialArgs = { inherit self; };
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs makeConfig hardwareConfigs;
    };
}