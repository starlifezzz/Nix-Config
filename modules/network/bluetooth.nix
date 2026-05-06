# ═══════════════════════════════════════════════════════════
# 蓝牙配置模块 - KDE Plasma 6 完整支持
# 参考官方文档: https://nixos.org/manual/nixos/unstable/options.html#opt-hardware.bluetooth.enable
# ═══════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 启用蓝牙硬件支持
  # ═══════════════════════════════════════════════════════════
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    
    # 配置蓝牙主配置文件 - 启用所有必要功能
    settings = {
      General = {
        # ControllerMode=dual 支持 BR/EDR 和 LE 设备
        ControllerMode = "dual";
        # 允许远程设备发现
        DiscoverableTimeout = 0;
        # 允许配对
        PairableTimeout = 0;
        # 启用经典蓝牙和低功耗蓝牙
        Experimental = true;
      };
      
      Policy = {
        # 自动启用蓝牙适配器
        AutoEnable = true;
        # 允许自动配对已知设备
        AutoPin = true;
      };
    };
    
    # 启用输入服务配置（键盘、鼠标等）
    input = {
      General = {
        # 启用 HIDP 支持
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
  # 启用 Blueman 蓝牙管理器 - KDE Plasma 6 兼容
  # 参考官方文档: https://nixos.org/manual/nixos/unstable/options.html#opt-services.blueman.enable
  # ═══════════════════════════════════════════════════════════
  services.blueman = {
    enable = true;
    # 启用托盘图标
    enableTray = true;
    # 启用通知
    enableNotifications = true;
  };

  # ═══════════════════════════════════════════════════════════
  # 确保必要的蓝牙相关包可用
  # ═══════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    bluez # 蓝牙协议栈
    blueman # 蓝牙管理器 GUI
  ];

  # ═══════════════════════════════════════════════════════════
  # KDE Plasma 6 蓝牙集成
  # ═══════════════════════════════════════════════════════════
  # 确保 KDE Connect 能够正常工作
  environment.sessionVariables = {
    # 确保蓝牙设备能够被正确识别
    XDG_CURRENT_DESKTOP = "KDE";
  };
}