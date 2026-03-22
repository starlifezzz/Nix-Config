{
  description = "NixOS configuration with automatic hardware-specific module loading";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 添加官方 nixos-hardware 支持
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }: {
    
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = { inherit self; };
      
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        ./modules/hardware/default.nix
        
        # AMD CPU 通用优化（使用官方 nixos-hardware）
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-pc-ssd
        
        # Home Manager 配置
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