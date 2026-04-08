{
  description = "NixOS configuration - Simple manual hardware selection";

  inputs = {
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
      
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };
      
      # 引入 Nixpkgs lib（用于 mkForce 等函数）
      lib = nixpkgs.lib;
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
            
            # ═══════════════════════════════════════════════════════════
            # Home Manager 集成（仅作为模块加载器）
            # 具体配置在 configuration.nix 中定义
            # ═══════════════════════════════════════════════════════════
            home-manager.nixosModules.home-manager
          ];
        };
      };
      
      packages.${system} = {
        default = self.nixosConfigurations.nixos.config.system.build.toplevel;
      };
    };
}