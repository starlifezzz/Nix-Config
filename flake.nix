{
  description = "NixOS configuration with modular hardware support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zhangchongjie = import ./home/home.nix;
          
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
          
          hardware.cpu = {
            enable = true;
            manualModel = "ryzen-1600x";
          };
          
          hardware.gpu = {
            enable = true;
            manualModel = "r9-370";
          };
        }
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zhangchongjie = import ./home/home.nix;
          
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
          
          hardware.cpu = {
            enable = true;
            manualModel = "ryzen-2600";
          };
          
          hardware.gpu = {
            enable = true;
            manualModel = "rx-5500xt";
          };
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