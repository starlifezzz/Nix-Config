# ═══════════════════════════════════════════════════════════
# 网络配置模块
# ═══════════════════════════════════════════════════════════

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
      # ✅ 启用连接拒绝日志记录 - 便于安全审计
      logRefusedConnections = true;
      
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

  # Linux 7.0 网络性能优化
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 134217728; # 增加接收缓冲区最大值到128MB
    "net.core.wmem_max" = 134217728; # 增加发送缓冲区最大值到128MB
    "net.ipv4.tcp_rmem" = "4096 262144 134217728"; # TCP接收内存：min default max
    "net.ipv4.tcp_wmem" = "4096 65536 134217728"; # TCP发送内存：min default max
    "net.core.netdev_max_backlog" = 5000; # 增加网络设备输入队列长度
    "net.ipv4.tcp_fastopen" = 3; # 减少 Clash 代理连接的握手延迟 (0: 关闭, 1: 客户端, 2: 服务器, 3: 两者)
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
        # DNS = "119.29.29.29 223.5.5.5";
        # ✅ Fallback DNS: 国际 DNS (当国内 DNS 失败时使用)
        # FallbackDNS = "1.1.1.1 8.8.8.8";
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
    # allowInterfaces = [ "lo" "*" ];
    
  };

}