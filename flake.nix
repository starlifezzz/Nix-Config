{
  description = "NixOS configuration with modular hardware support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        
        # 自动根据当前系统的主机名选择硬件
        ({ config, lib, pkgs, ... }: {
          networking.hostName = lib.mkDefault "nixos";
          
          # 如果主机名是 "nixos"，使用 ryzen-2600 + rx-5500xt
          hardware.cpu.manualModel = lib.mkDefault "ryzen-2600";
          hardware.gpu.manualModel = lib.mkDefault "rx-5500xt";
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
    
    nixosConfigurations.nixos-1600x-r9370 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        
        {
          networking.hostName = "nixos-1600x-r9370";
          hardware.cpu.manualModel = "ryzen-1600x";
          hardware.gpu.manualModel = "r9-370";
        }
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zhangchongjie = import ./home;
          
          home-manager.extraSpecialArgs = { inherit self; };
        }
      ];
    };
    
    nixosConfigurations.nixos-2600-rx5500xt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        
        {
          networking.hostName = "nixos-2600-rx5500xt";
          hardware.cpu.manualModel = "ryzen-2600";
          hardware.gpu.manualModel = "rx-5500xt";
        }
        
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