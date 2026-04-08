# ═══════════════════════════════════════════════════════════
# 网络配置模块
# ═══════════════════════════════════════════════════════════
{ config, lib, pkgs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # 基础网络配置
  # ═══════════════════════════════════════════════════════════
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    # ═══════════════════════════════════════════════════════════
    # 防火墙配置 - 支持 Clash TUN 模式
    # ═══════════════════════════════════════════════════════════
    firewall = {
      enable = true;
      allowPing = true;
      checkReversePath = true;
      
      # 允许 Clash TUN 模式的虚拟网卡流量
      trustedInterfaces = [
        "Mihomo"  # Clash Verge Rev 的 TUN 接口
        "Meta"    # Clash Meta 内核的备选 TUN 接口
      ];
      
      # 开放 KDE Connect 端口
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }
      ];
    };
  };

  # DNS 配置 - 使用 NetworkManager（已禁用 systemd-resolved 避免冲突）
  # 在 NetworkManager 中配置：119.29.29.29, 223.5.5.5

  # systemd-resolved DNS 服务（与 NetworkManager 协同工作）
  # ⚠️ 注意：如果 NetworkManager DNS 工作正常，可以禁用此服务避免冲突
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSStubListener = "yes";
        # ✅ 主 DNS: 国内 DNS (快速解析国内域名)
        DNS = "119.29.29.29 223.5.5.5";
        # ✅ Fallback DNS: 国际 DNS (当国内 DNS 失败时使用)
        FallbackDNS = "1.1.1.1 8.8.8.8";
        DNSSEC = "false";
      };
    };
  };

  # Avahi 服务（mDNS）
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
    };
  };
}
