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
      
      specialArgs = { inherit self; };
      
      modules = [
        ./configuration.nix
        ./modules/amd-gpu.nix
        ./modules/hardware/default.nix
        
        # ═══════════════════════════════════════════════════════════
        # 硬件检测与模块加载
        # ═══════════════════════════════════════════════════════════
        ({ config, lib, pkgs, ... }: 
          let
            # 在激活时检测硬件并生成配置文件
            detectAndGenerate = ''
              echo ">>> ═══════════════════════════════════════════════════════════"
              echo ">>> Running hardware detection..."
              
              # CPU 检测
              if grep -q "AMD Ryzen 5 1600X" /proc/cpuinfo 2>/dev/null; then
                CPU_MODEL="ryzen-1600x"
                echo ">>> ✓ Detected: AMD Ryzen 5 1600X"
              elif grep -q "AMD Ryzen 5 2600" /proc/cpuinfo 2>/dev/null; then
                CPU_MODEL="ryzen-2600"
                echo ">>> ✓ Detected: AMD Ryzen 5 2600"
              elif grep -q "AMD Ryzen 5 3600" /proc/cpuinfo 2>/dev/null; then
                CPU_MODEL="ryzen-3600"
                echo ">>> ✓ Detected: AMD Ryzen 5 3600"
              else
                CPU_MODEL="unknown-cpu"
                echo ">>> ⚠ Unknown CPU detected"
              fi
              
              # GPU 检测 - 只保留 RX 5500 (7340)
              if lspci -nn 2>/dev/null | grep -E '\[1002:7340\]' >/dev/null 2>&1; then
                GPU_MODEL="rx-5500"
                echo ">>> ✓ Detected: AMD Radeon RX 5500 [1002:7340]"
              elif lspci -nn 2>/dev/null | grep -E '\[1002:66af\]' >/dev/null 2>&1; then
                GPU_MODEL="r9-370"
                echo ">>> ✓ Detected: AMD Radeon R9 370 [1002:66af]"
              else
                GPU_MODEL="unknown-gpu"
                echo ">>> ⚠ Unknown GPU detected"
              fi
              
              echo ">>> Detected: CPU=$CPU_MODEL, GPU=$GPU_MODEL"
              
              # 生成硬件配置文件（如果不存在）
              if [ ! -f /etc/nixos/hardware-auto.nix ]; then
                cat > /etc/nixos/hardware-auto.nix << EOF
# Auto-generated hardware configuration
# Generated at: $(date)
# DO NOT EDIT MANUALLY

{ config, lib, pkgs, ... }:

{
  hardware.cpu.manualModel = lib.mkDefault "$CPU_MODEL";
  hardware.gpu.manualModel = lib.mkDefault "$GPU_MODEL";
  
  networking.hostName = lib.mkDefault ("nixos-" + "$CPU_MODEL" + "-" + "$GPU_MODEL");
}
EOF
                echo ">>> Generated /etc/nixos/hardware-auto.nix"
              else
                echo ">>> /etc/nixos/hardware-auto.nix already exists, skipping generation"
              fi
              
              echo ">>> ═══════════════════════════════════════════════════════════"
            '';
            
          in {
            # 在首次激活时检测硬件并生成配置文件
            system.activationScripts.preActivation.text = lib.mkBefore detectAndGenerate;
            
            # 导入自动生成的硬件配置（如果存在）
            imports = lib.optionals (builtins.pathExists ./hardware-auto.nix) [
              ./hardware-auto.nix
            ];
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