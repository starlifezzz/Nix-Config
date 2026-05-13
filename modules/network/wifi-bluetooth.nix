# ═══════════════════════════════════════════════════════════
# WiFi 和蓝牙配置模块
# 参考官方文档: 
# - https://nixos.org/manual/nixos/unstable/options.html#opt-hardware.bluetooth.enable
# - https://nixos.org/manual/nixos/unstable/options.html#opt-networking.networkmanager.enable
# ═══════════════════════════════════════════════════════════
{ pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # WiFi配置 - NetworkManager管理
  # ═══════════════════════════════════════════════════════════
  networking.networkmanager.wifi = {
    backend = "iwd"; # 使用iwd作为WiFi后端（可选，也可使用wpa_supplicant）
    # 如果需要使用wpa_supplicant，可以注释上面一行并取消下面的注释
    # backend = "wpa_supplicant";
  };

  # ═══════════════════════════════════════════════════════════
  # 蓝牙配置
  # ═══════════════════════════════════════════════════════════
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    
    # 配置蓝牙主配置文件 - 启用所有必要功能
    settings = {
      General = {
        ControllerMode = "dual"; # 支持 BR/EDR 和 LE 设备
        DiscoverableTimeout = 0; # 允许远程设备发现
        PairableTimeout = 0; # 允许配对
        Experimental = true; # 启用经典蓝牙和低功耗蓝牙
      };
      
      Policy = {
        AutoEnable = true; # 自动启用蓝牙适配器
        # AutoPin = true; # 移除AutoPin配置，因为当前版本不支持
      };
    };
    
    # 启用输入服务配置（键盘、鼠标等）
    input = {
      General = {
        ReconnectAttempts = 7;
        ReconnectIntervals = "1,2,4,8,16,32,64";
      };
    };
    
    # 启用网络服务配置（PAN/NAP）
    network = {
      General = {
        DisableSecurity = false;
        DNSSearch = true;
      };
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 蓝牙管理器 - 禁用Blueman以避免服务冲突
  # ═══════════════════════════════════════════════════════════
  # services.blueman.enable = false; # 完全注释掉，避免配置冲突

  # ═══════════════════════════════════════════════════════════
  # 必要的系统包
  # ═══════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    bluez # 蓝牙协议栈
    # blueman # 蓝牙管理器 GUI - 已禁用
    # WiFi相关工具
    iw
    wirelesstools
  ];
}