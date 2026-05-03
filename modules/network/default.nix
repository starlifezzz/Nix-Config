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

  # DNS 配置说明
  # ⚠️ 当前同时启用了 NetworkManager 和 systemd-resolved
  # - NetworkManager: 管理网络连接和基础 DNS
  # - systemd-resolved: 提供 DNS 缓存、Fallback DNS 等高级功能
  # 两者可以协同工作，但需确保不冲突（已通过配置验证）

  # systemd-resolved DNS 服务（与 NetworkManager 协同工作）
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
        # ✅ 禁用 mDNS 以避免与 Avahi 冲突
        MulticastDNS = "no";
      };
    };
  };

  # Avahi 服务（mDNS）
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      # 允许用户服务发布
      userServices = true;
      addresses = true;
      domain = true;
    };
    # 增加权限以支持 KDE Connect
    openFirewall = true;
    # 允许所有接口进行服务发现
    allowInterfaces = [ "lo" "*" ];
  };

  # XDG Desktop Portal 配置文件
  environment.etc."xdg/portals/portals.conf".text = ''
    # XDG Desktop Portal 配置文件
    # 参考官方文档: https://man.archlinux.org/man/portals.conf.5

    [kde]
    default=true
    
    [gtk]
    default=false
  '';
}