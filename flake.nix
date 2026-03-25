{
  description = "NixOS configuration with flexible hardware selection";

  inputs = {
    # 使用 GitHub 原生格式（推荐，最稳定）
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # 如果 GitHub 访问慢，可以使用以下备选方案：
    # 方案 1: 使用中科大 Git 镜像（较稳定）
    # nixpkgs.url = "git+https://mirrors.ustc.edu.cn/nix-channels/nixpkgs.git?ref=nixos-25.11";
    
    # 方案 2: 使用 gitmirror 镜像
    # nixpkgs.url = "git+https://gitmirror.com/github.com/NixOS/nixpkgs?ref=nixos-25.11";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Flatpak 应用管理
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, nix-flatpak, ... }:
    let
      # 预定义模块路径（避免在函数内重复计算）
      detectionModule = ./modules/hardware/detection.nix;
      
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
            
            # 基础硬件检测模块
            detectionModule
            
            # 动态导入硬件特定配置
            ({ config, lib, pkgs, ... }: {
              imports = 
                lib.optional (builtins.pathExists ./modules/hardware/cpu/${hw.cpu}.nix)
                  ./modules/hardware/cpu/${hw.cpu}.nix
                ++ lib.optional (builtins.pathExists ./modules/hardware/gpu/${hw.gpu}.nix)
                  ./modules/hardware/gpu/${hw.gpu}.nix;
              
              networking.hostName = lib.mkDefault hw.hostName;
              
              hardware.cpu.manualModel = hw.cpu;
              hardware.gpu.manualModel = hw.gpu;
            })
            
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              
              # 文件冲突时自动备份到带时间戳的文件
              home-manager.backupFileExtension = "hm-backup";
              
              # 使用 default.nix 统一管理所有用户配置
              home-manager.users.zhangchongjie = import ./home;
              
              home-manager.extraSpecialArgs = { inherit self nix-flatpak; };
            }
          ];
        };
    in
    {
      nixosConfigurations = builtins.mapAttrs makeConfig hardwareConfigs;
    };
}