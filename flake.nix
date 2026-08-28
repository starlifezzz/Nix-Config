{
  description = "NixOS configuration - Simple manual hardware selection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # DankMaterialShell（GitHub input——只用作 home-manager 模块来源）
    # 包用 nixpkgs 的 dms-shell（构建稳定 + 更新由 nixpkgs 管）
    # 更新: nix flake update dms（模块）+ nixpkgs 升级 dms-shell（包）
    dms.url = "github:AvengeMedia/DankMaterialShell";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      dms,
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
            # DMS home-manager 模块注入（官方 flake）
            # dank-material-shell: 主模块（programs.dank-material-shell + dms.service）
            # niri: niri 集成选项（niri.includes/keybinds/spawn）
            {
              home-manager.users.zhangchongjie.imports = [
                # DMS 主模块（programs.dank-material-shell + dms.service）
                # 注: dms.homeModules.niri 依赖 niri-flake（programs.niri），
                #     我们用 home-manager 的 wayland.windowManager.niri，不兼容——niri 集成手动做
                dms.homeModules.dank-material-shell
              ];
            }

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
