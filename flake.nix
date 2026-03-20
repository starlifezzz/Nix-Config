{
  description = "NixOS configuration";
   inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 添加额外的 flake 输入（可选）
    # nur = {
    #   url = "github:nix-community/NUR";
    # };
  };

 outputs = { nixpkgs, home-manager, ... }: {
    
    # 主机 1: Ryzen 1600X + R9 370
    nixosConfigurations.host-1600x-r9370 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        
        {
          networking.hostName = "nixos-1600x-r9370";
          
          # 指定硬件配置
          hardware.cpu = {
            enable = true;
            manualModel = "ryzen-1600x";
          };
          
          hardware.gpu = {
            enable = true;
            manualModel = "r9-370";
          };
          
          # 或者使用自动检测
          # hardware.cpu.autoDetect = true;
          # hardware.gpu.autoDetect = true;
        }
      ];
    };
    
    # 主机 2: Ryzen 2600 + RX 5500XT
    nixosConfigurations.host-2600-rx5500xt = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        
        {
          networking.hostName = "nixos-2600-rx5500xt";
          
          hardware.cpu = {
            enable = true;
            manualModel = "ryzen-2600";
          };
          
          hardware.gpu = {
            enable = true;
            manualModel = "rx-5500xt";
          };
        }
      ];
    };
    
    # 默认配置（自动检测）
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        
        {
          networking.hostName = "nixos";
          
          hardware.cpu = {
            enable = true;
            autoDetect = true;
          };
          
          hardware.gpu = {
            enable = true;
            autoDetect = true;
          };
        }
      ];
    };
  };
}