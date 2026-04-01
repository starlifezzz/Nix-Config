{ config, lib, pkgs, ... }:

# ═══════════════════════════════════════════════════════════
# 游戏手柄支持配置模块
# ═══════════════════════════════════════════════════════════
# 功能：
# - Xbox 系列手柄原生支持
# - 北通鲲鹏 20 强制 Xbox 模式（1000Hz 高回报率）
# - Steam Input 集成
# - 通用第三方手柄支持
# 
# 使用方式：
# 在 configuration.nix 的 imports 中添加此模块路径
# ═══════════════════════════════════════════════════════════

{
  # ───────────────────────────────────────────────────────
  # 核心服务与驱动
  # ───────────────────────────────────────────────────────
  
  # ✅ 启用 Steam 及控制器支持
  # programs.steam = {
  #   enable = true;
  #   protontricks.enable = true;      # Proton 工具支持
  #   remotePlay.enable = true;         # 远程同乐
  #   controllerSupport.enable = true;  # 手柄支持
  # };
  
  # ✅ 图形和输入设备支持
  hardware.graphics.enable = true;        # Vulkan/OpenGL 支持
  hardware.opentabletdriver.enable = true; # 平板/特殊输入设备
  
  # ───────────────────────────────────────────────────────
  # 用户组权限
  # ───────────────────────────────────────────────────────
  
  users.users.zhangchongjie.extraGroups = [ 
    "gamemode"   # 游戏性能模式
    "input"      # 输入设备访问权限（手柄必需）
  ];
  
  # ───────────────────────────────────────────────────────
  # udev 规则 - 设备识别与驱动绑定
  # ───────────────────────────────────────────────────────
  
  services.udev.extraRules = ''
    # ═══════════════════════════════════════════════════════
    # 北通鲲鹏 20 (Betop 鲲鹏 20) - USB ID: 2c22
    # 问题：默认被识别为 Switch 手柄，无法使用 1000Hz 回报率
    # 解决：强制使用 xpad 驱动，启用 Xbox 模式
    # ═══════════════════════════════════════════════════════
    
    # USB 设备识别
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2c22", ATTRS{idProduct}=="*", ENV{ID_INPUT_JOYSTICK}="1"
    
    # 解除 Switch 模式绑定（如果已错误识别为 Nintendo 控制器）
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="*Betop*", RUN+="/bin/sh -c 'echo -n %k > /sys/bus/hid/drivers/xpad/bind'"
    
    # 设置高轮询率（USB 间隔 1ms = 1000Hz，需硬件支持）
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2c22", ATTR{bInterval}="1"
    
    # ═══════════════════════════════════════════════════════
    # Xbox 系列手柄通用规则
    # ═══════════════════════════════════════════════════════
    
    # Xbox One / Xbox Series X|S 手柄
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="*X-Box*", ENV{ID_INPUT_JOYSTICK}="1"
    
    # Xbox 360 手柄
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="028e", ENV{ID_INPUT_JOYSTICK}="1"
    
    # ═══════════════════════════════════════════════════════
    # 其他第三方手柄（备用规则）
    # ═══════════════════════════════════════════════════════
    
    # 通用 Xbox 兼容手柄
    ACTION=="add", SUBSYSTEM=="input", ATTRS{name}=="*Controller*", ATTRS{id/vendor}=="*", ENV{ID_INPUT_JOYSTICK}="1"
  '';
  
  # ───────────────────────────────────────────────────────
  # 内核模块
  # ───────────────────────────────────────────────────────
  
  # ✅ 确保 xpad 驱动加载（Xbox 手柄核心驱动）
  boot.kernelModules = [ "xpad" ];
  
  # ───────────────────────────────────────────────────────
  # 系统工具包
  # ───────────────────────────────────────────────────────
  
  environment.systemPackages = with pkgs; [
    # 手柄测试工具
    jstest-gtk          # GUI 手柄测试工具
    sdl2                # SDL2 库（游戏兼容层）
    vulkan-tools        # Vulkan 工具集
    
    # 可选：高级手柄配置工具
    # xboxdrv           # Xbox 手柄驱动（如需额外功能）
    # qjoypad           # 手柄映射工具
  ];
  
  # ───────────────────────────────────────────────────────
  # 故障排查说明
  # ───────────────────────────────────────────────────────
  # 
  # 部署后验证步骤：
  # 1. 重启系统：reboot
  # 2. 查看手柄识别：lsusb | grep -i betop
  # 3. 查看输入设备：cat /proc/bus/input/devices | grep -A 10 -i betop
  # 4. 检查驱动绑定：ls /sys/bus/hid/drivers/xpad/
  # 5. 测试手柄：jstest-gtk
  #
  # 常见问题：
  # A. 仍识别为 Switch 手柄：
  #    sudo modprobe -r hid-nintendo
  #    sudo udevadm control --reload-rules
  #    sudo udevadm trigger
  #    重新插拔手柄
  #
  # B. xpad 驱动未加载：
  #    lsmod | grep xpad
  #    sudo modprobe xpad
  #
  # C. 权限不足：
  #    groups zhangchongjie | grep input
  #    重新登录或执行：newgrp input
  #
  # ═══════════════════════════════════════════════════════
}
