{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 添加额外的 flake 输入（可选）
    # nur = {
    #   url = "github:nix-community/NUR";
    # };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.zhangchongjie = import ./home/home.nix;
          
          # 添加系统级优化
          system.autoUpgrade = {
            enable = false;  # 禁用自动升级，手动控制
            allowReboot = false;
          };
        }
      ];
    };
  };
}