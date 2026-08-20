# /etc/nixos/modules/hardware/fingerprint.nix
# USB 指纹识别器 (Synaptics Prometheus 06cb:00df)
# 分支: main —— 独立硬件模块，与桌面环境解耦
#
# 官方文档:
#   services.fprintd.enable:        https://search.nixos.org/options?show=services.fprintd.enable
#   services.fprintd.tod.enable:    https://search.nixos.org/options?show=services.fprintd.tod.enable
#   services.fprintd.tod.driver:    https://search.nixos.org/options?show=services.fprintd.tod.driver
#   security.pam.services.sddm.fprintAuth: https://search.nixos.org/options?show=security.pam.services.sddm.fprintAuth
#   security.pam.services.sudo.fprintAuth: https://search.nixos.org/options?show=security.pam.services.sudo.fprintAuth
#
# 硬件支持依据（2026-08-20 实证审核）:
#   - USB ID: 06cb:00df（journalctl: "usb 1-3: New USB device found, idVendor=06cb, idProduct=00df"）
#   - fwupd 识别: Prometheus, 固件 10.01.3654703 已最新（无更新可用）
#   - libfprint-tod 1.94.9+tod1 源码 synaptics.c:38 硬编码支持: { .vid = SYNAPTICS_VENDOR_ID, .pid = 0x00DF }
#   - Synaptics Prometheus 属 match-on-chip (TOD) 设备 → 必须 tod.enable = true
{ pkgs, lib, ... }:

{
  # ── 指纹认证服务 (fprintd + libfprint-tod) ────────────────
  # 目的：启动 fprintd 守护进程并安装 libfprint 驱动（含 Synaptics TOD 驱动）
  # 依赖：本机 USB 指纹锁 06cb:00df；与 SDDM/KDE 无冲突（fprintd 是独立 D-Bus 服务）
  services.fprintd = {
    enable = true;
    # Synaptics Prometheus 是 match-on-chip 设备，必须启用 TOD (Touch-On-Display) 驱动
    tod.enable = true;
  };

  # ── SDDM 登录启用指纹认证 ─────────────────────────────────
  # 目的：登录界面显示指纹按钮，PAM 链新增可选指纹模块（失败自动回退密码）
  # 依赖：services.fprintd.enable = true
  security.pam.services.sddm.fprintAuth = true;

  # ── sudo 启用指纹认证（可选，按需启用）────────────────────
  # 说明：当前注释状态 = sudo 仅密码。需要 sudo 也支持指纹时取消注释并重建。
  # security.pam.services.sudo.fprintAuth = true;
}
