{
  description = "NixOS configuration - Simple manual hardware selection";

  inputs = {
    # 使用国内镜像源加速访问
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
    let
      system = "x86_64-linux";
      
      # 配置 Nix 使用国内镜像源
      nixConfig = {
        extra-substituters = [
          "https://mirrors.ustc.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
        ];
        extra-trusted-public-keys = [
          "nix-cache.nixos.org:/S8Ab5KwBhUd0RbHjOqg+2qdGkCv+o3yD7aWfL+QZ9xY="
        ];
      };
      
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          
          specialArgs = {
            inherit self pkgs-unstable;
          };
          
          modules = [
            ./configuration.nix
            
            # Home Manager 集成
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit self pkgs-unstable; };
              
              # Nix 下载配置
              nix.settings = {
                substituters = [
                  "https://mirrors.ustc.edu.cn/nix-channels/store"
                  "https://mirror.sjtu.edu.cn/nix-channels/store"
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ];
              };
            }
          ];
        };
      };
      
      packages.${system} = {
        default = self.nixosConfigurations.nixos.config.system.build.toplevel;
      };
    };
}
