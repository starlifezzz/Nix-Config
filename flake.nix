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

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }: {
    
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = { inherit self; };
      
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        ./modules/hardware/default.nix
        
        nixos-hardware.nixosModules.common-cpu-amd
        nixos-hardware.nixosModules.common-pc-ssd
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