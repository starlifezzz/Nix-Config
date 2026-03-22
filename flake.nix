{
  description = "NixOS configuration with automatic hardware-specific module loading";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = {
        inherit self;
      };
      
      modules = [
        ./configuration.nix
        
        # ═══════════════════════════════════════════════════════════
        # 自动硬件检测与模块加载
        # ═══════════════════════════════════════════════════════════
        ({ config, lib, pkgs, ... }: 
          let
            # 运行检测脚本获取硬件信息
            detectHardwareScript = pkgs.writeShellScriptBin "detect-hardware" ''
              ${./scripts/detect-hardware.sh} json
            '';
            
            # 执行检测并解析结果
            hardwareInfo = builtins.fromJSON (
              builtins.readFile (
                pkgs.runCommand "hardware-detection" {} ''
                  ${detectHardwareScript}/bin/detect-hardware > $out
                ''
              )
            );
            
            cpuModel = hardwareInfo.cpu or "unknown";
            gpuModel = hardwareInfo.gpu or "unknown";
            
            # 动态生成模块导入列表
            cpuModulePath = ./modules/hardware/cpu/${cpuModel}.nix;
            gpuModulePath = ./modules/hardware/gpu/${gpuModel}.nix;
            
            # 检查模块文件是否存在
            hasCpuModule = builtins.pathExists cpuModulePath;
            hasGpuModule = builtins.pathExists gpuModulePath;
            
            # 构建模块列表
            hardwareModules = []
              ++ lib.optionals hasCpuModule [ cpuModulePath ]
              ++ lib.optionals hasGpuModule [ gpuModulePath ];
            
          in {
            # 在系统激活时显示检测信息
            system.activationScripts.preActivation.text = lib.mkBefore ''
              echo ">>> ═══════════════════════════════════════════════════════════"
              echo ">>> Hardware Detection Results:"
              echo ">>>   CPU Model: $cpuModel ${if hasCpuModule then "(module found)" else "(no specific module)"}"
              echo ">>>   GPU Model: $gpuModel ${if hasGpuModule then "(module found)" else "(no specific module)"}"
              echo ">>> Hostname: ${config.networking.hostName}"
              echo ">>> ═══════════════════════════════════════════════════════════"
              
              # 保存检测结果到配置文件
              cat > /etc/nixos/.hardware-detected.json << EOF
            ${builtins.toJSON hardwareInfo}
            EOF
                        '';
                        
                        # 动态导入硬件模块
                        imports = hardwareModules;
                        
                        # 设置主机名（基于检测到的硬件）
                        networking.hostName = lib.mkDefault "nixos-${cpuModel}-${gpuModel}";
                      }
            )
        
        # Home Manager 配置
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