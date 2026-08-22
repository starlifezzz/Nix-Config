# ═══════════════════════════════════════════════════════════
# WiFi 和蓝牙配置模块
# 参考官方文档:
# - https://nixos.org/manual/nixos/unstable/options.html#opt-hardware.bluetooth.enable
# - https://nixos.org/manual/nixos/unstable/options.html#opt-networking.networkmanager.enable
# ═══════════════════════════════════════════════════════════

{

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
      };

      Policy = {
        AutoEnable = true;
      };
    };
  };

}
