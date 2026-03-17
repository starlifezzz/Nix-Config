{ config, pkgs, inputs, ... }:

{
  # ═══════════════════════════════════════════════════════════
  # Home Manager 基础配置
  # ═══════════════════════════════════════════════════════════
  home.username = "zhangchongjie";
  home.homeDirectory = "/home/zhangchongjie";
  home.stateVersion = "25.11";

  # ═══════════════════════════════════════════════════════════
  # 用户软件包
  # ═══════════════════════════════════════════════════════════
  home.packages = with pkgs; [
    # 浏览器
    firefox

    # 其他
    flatpak
    kdePackages.kate
    kdePackages.kdeconnect-kde
  ];

  # ═══════════════════════════════════════════════════════════
  # Fish Shell 配置
  # ═══════════════════════════════════════════════════════════
  programs.fish = {
    enable = true;

    shellInit = ''
      # 代理端口
      set -gx CLASH_PORT 7897
    '';

    functions = {
      # 开启代理
      proxy_on = ''
        set -gx http_proxy http://127.0.0.1:$CLASH_PORT
        set -gx https_proxy http://127.0.0.1:$CLASH_PORT
        set -gx all_proxy socks5://127.0.0.1:(math $CLASH_PORT + 1)
        set -gx no_proxy localhost,127.0.0.1,192.168.0.0/16,10.0.0.0/8,.local,.cn
        echo "✅ Proxy ON"
      '';

      # 关闭代理
      proxy_off = ''
        set -e http_proxy
        set -e https_proxy
        set -e all_proxy
        echo "❌ Proxy OFF"
      '';

      # 查看状态
      proxy_status = ''
        if set -q https_proxy
          echo "✅ Proxy: $https_proxy"
        else
          echo "⚠️ Proxy: Not set"
        end
      '';

      # 带代理 sudo
      sudoproxy = ''
        sudo -E $argv
      '';

      # 🔴 Flakes 重建命令（使用国内镜像）
      rebuild-flake = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos \
          --option substituters "https://mirrors.cernet.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store" \
          --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      '';

      # 🔴 离线重建命令
      rebuild-offline = ''
        sudo -E nixos-rebuild switch --flake /etc/nixos#nixos --offline
      '';
    };

    shellAliases = {
      ll = "ls -la";
      la = "ls -A";
      rebuild = "sudo -E nixos-rebuild switch";
      rebuild-test = "sudo -E nixos-rebuild test";
      hm-switch = "home-manager switch";
      rebuild-flake = "rebuild-flake";
      rebuild-offline = "rebuild-offline";
    };

    interactiveShellInit = ''
      proxy_status
    '';
  };

  # ═══════════════════════════════════════════════════════════
  # Git 配置
  # ═══════════════════════════════════════════════════════════
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "zhangchongjie";
        email = "778280151@qq.com";
      };

      init = {
        defaultBranch = "main";
      };

      core = {
        editor = "vim";
      };

      url."https://github.com/" = {
        insteadOf = "git://github.com/";
      };
    };
  };

   # ═══════════════════════════════════════════════════════════
  # VSCode 配置
  # ═══════════════════════════════════════════════════════════
  programs.vscode = {
    enable = true;

    # ✅ 新格式：使用 profiles.default
    profiles.default = {
      # 扩展
      extensions = with pkgs.vscode-extensions; [
        # 示例：
        # ms-python.python
        # ms-vscode.cpptools
      ];

      # 用户设置
      userSettings = {
        "editor.fontSize" = 14;
        "workbench.colorTheme" = "Default Dark+";
      };
    };
  };

  # ═══════════════════════════════════════════════════════════
  # 环境变量
  # ═══════════════════════════════════════════════════════════
  home.sessionVariables = {
    XDG_DATA_DIRS = "/nix/var/nix/profiles/default/share:/run/current-system/sw/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  # ═══════════════════════════════════════════════════════════
  # 启用 Home Manager
  # ═══════════════════════════════════════════════════════════
  programs.home-manager.enable = true;
}
