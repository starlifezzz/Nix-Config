{
  description = "NixOS configuration - Simple manual hardware selection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # ═══ Home Manager: 使用 nixpkgs 内置的 CLI 包（standalone 模式）═══
    # 不再引用 github:nix-community/home-manager（避免每次 rebuild 拉源码）
    # 使用方法：home-manager switch -f /etc/nixos/home/default.nix
    # ═══ DMS (DankMaterialShell) 完全由 nixpkgs 管理 ═══
    # 包 + NixOS 模块（programs.dms-shell）都在 nixpkgs
    # 更新 = nixpkgs 升级（nix flake update nixpkgs）
    # settings.json 由 home.file 声明（见 home/dms.nix）
  };

  outputs =
    {
      self,
      nixpkgs,
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
          ];
        };
      };

      packages.${system} = {
        default = self.nixosConfigurations.nixos.config.system.build.toplevel;
      };
    };
}
