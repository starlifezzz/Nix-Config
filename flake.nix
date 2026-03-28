{
  description = "NixOS configuration with flexible hardware selection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;

      # ✅ 添加 unstable pkgs 用于获取最新 VSCode
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
        config.allowBroken = true;
      };

      # ✅ 动态扫描 CPU 和 GPU 模块文件
      cpuFiles = builtins.readDir ./modules/hardware/cpu;
      gpuFiles = builtins.readDir ./modules/hardware/gpu;

      # 提取文件名（去掉 .nix 后缀）
      cpus = lib.filter (x: x != "unknown-cpu")
        (map (name: lib.removeSuffix ".nix" name)
          (lib.attrNames cpuFiles));

      gpus = lib.filter (x: x != "unknown-gpu")
        (map (name: lib.removeSuffix ".nix" name)
          (lib.attrNames gpuFiles));


      # ✅ 生成所有可能的硬件组合（移除环境变量默认值）
      allHardwareConfigs = lib.listToAttrs (
        lib.concatMap (cpu:
          lib.concatMap (gpu:
            [
              {
                name = "nixos-${cpu}-${gpu}";
                value = {
                  inherit cpu gpu;
                  hostName = "nixos-${cpu}-${gpu}";
                };
              }
            ]
          ) gpus
        ) cpus
      );

      makeConfig = name: hw:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit (hw) cpu gpu;
            inherit self pkgs-unstable;
          };

          modules = [
            ./configuration.nix

            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc-ssd

            # 基础硬件检测模块
            ./modules/hardware/detection.nix

            # ✅ 动态导入对应的 CPU 和 GPU 模块
            ({ config, lib, pkgs, ... }: {
              # 先设置 manualModel（在模块导入前）
              hardware.cpu.manualModel = hw.cpu;
              hardware.gpu.manualModel = hw.gpu;
              networking.hostName = lib.mkDefault hw.hostName;
            })

            # 直接导入模块文件（路径一定存在）
            ./modules/hardware/cpu/${hw.cpu}.nix
            ./modules/hardware/gpu/${hw.gpu}.nix

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              # ⚠️ backupFileExtension 已移至 configuration.nix 统一管理
              home-manager.extraSpecialArgs = { inherit self pkgs-unstable; };
            }
          ];
        };

      # ✅ 预先生成所有配置，避免重复计算
      nixosConfigs = lib.mapAttrs' (name: config:
        lib.nameValuePair name (makeConfig name config)
      ) allHardwareConfigs;

      # ═══════════════════════════════════════════════════════════
      # ✅ Home Manager 独立配置（与 NixOS 分离）
      # ═══════════════════════════════════════════════════════════
      homeConfigurations = {
        "zhangchongjie" = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs-unstable;  # 使用 unstable pkgs 获取最新软件
          
          modules = [
            ./home/default.nix
          ];
          
          extraSpecialArgs = {
            inherit self pkgs-unstable;
          };
        };
      };

      # ✅ 使用第一个配置作为 default（或可通过环境变量覆盖）
      defaultCPU = "ryzen-2600";
      defaultGPU = "rx-5500";
      defaultConfigKey = "nixos-${defaultCPU}-${defaultGPU}";
      defaultNixosConfig = nixosConfigs.${defaultConfigKey} or
        (builtins.abort "Default configuration '${defaultConfigKey}' not found. Available configurations: ${builtins.concatStringsSep ", " (lib.attrNames nixosConfigs)}");
    in
    {
      # ✅ 自动生成所有组合的配置
      nixosConfigurations = nixosConfigs // {
        # ✅ 添加 default 别名指向默认配置
        default = defaultNixosConfig;

        # ✅ 添加简短别名 "nixos" 指向默认配置（方便命令使用）
        nixos = defaultNixosConfig;
      };

      # ✅ Home Manager 配置
      homeConfigurations = homeConfigurations // {
        # ✅ 添加默认别名
        default = homeConfigurations."zhangchongjie";
      };

      # ✅ 添加默认配置包 - 必须提供 nixos-rebuild 需要的属性
      packages.${system} = {
        default = defaultNixosConfig.config.system.build.toplevel;
        nixos = defaultNixosConfig.config.system.build.toplevel;
      } // lib.mapAttrs (_: config: config.config.system.build.toplevel) nixosConfigs;
    };
}
