{
  description = "NixOS configuration - Simple manual hardware selection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # ═══ DMS (DankMaterialShell) 完全由 nixpkgs 管理 ═══
    # 包 + NixOS 模块（programs.dms-shell）都在 nixpkgs
    # 更新 = nixpkgs 升级（nix flake update nixpkgs）
    # settings.json 由 home.file 声明（见 home/dms.nix）
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;

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
