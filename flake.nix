{
  description = "NixOS configuration with automatic hardware-specific module loading";

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
      supportedCPUs = [ "ryzen-1600x" "ryzen-2600" "ryzen-3600" ];
      supportedGPUs = [ "r9-370" "rx-5500" "rx-5500xt" "rx-5700" "rx-5700-xt" "rx-6600-xt" ];
      
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        specialArgs = { inherit self; };
        
        modules = [
          ./configuration.nix
          
          # 从 nixos-hardware 导入通用优化
          nixos-hardware.nixosModules.common-cpu-amd
          nixos-hardware.nixosModules.common-pc-ssd
          
          # 硬件检测模块（动态加载对应配置）
          ({ config, lib, pkgs, ... }: {
            options.hardware = {
              cpu.model = lib.mkOption {
                type = lib.types.enum supportedCPUs;
                default = "unknown";
              };
              gpu.model = lib.mkOption {
                type = lib.types.enum supportedGPUs;
                default = "unknown";
              };
            };
            
            config = {
              # 动态导入 CPU 配置
              imports = lib.optional (builtins.pathExists ./modules/hardware/cpu/${config.hardware.cpu.model}.nix)
                ./modules/hardware/cpu/${config.hardware.cpu.model}.nix;
              
              # 动态导入 GPU 配置
              imports = lib.optional (builtins.pathExists ./modules/hardware/gpu/${config.hardware.gpu.model}.nix)
                ./modules/hardware/gpu/${config.hardware.gpu.model}.nix;
              
              # 如果存在自动生成的配置文件则导入
              imports = lib.optional (builtins.pathExists ./hardware-auto.nix) ./hardware-auto.nix;
            };
          })
          
          # 基础硬件配置（所有设备共用）
          ./modules/hardware/detection.nix
          
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.zhangchongjie = import ./home;
            
            home-manager.extraSpecialArgs = { inherit self; };
          }
        ];
      };
    };
}