# /etc/nixos/home/fish.nix
# Fish Shell 配置

{
  programs.fish = {
    enable = true;

    shellAliases = {
      # ═══ 基础命令 ═══
      ll = "ls -la";
      la = "ls -A";
      c = "clear";
      s = "sudo";
      sk = "sudo killall -9";

      # ═══ 目录导航 ═══
      cdup = "cd ..";
      cd2up = "cd ../..";
      cd3up = "cd ../../..";

      # ═══ NixOS 系统管理（Flakes） ═══
      # 来源：https://nixos.org/manual/nixos/stable/#sec-changing-config
      # 去掉 -E：避免 "$HOME is not owned by you" 警告
      # TUN 模式下代理在网络层生效，不依赖环境变量
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      rebuild-test = "sudo nixos-rebuild test --flake /etc/nixos#nixos";
      rebuild-boot = "sudo nixos-rebuild boot --flake /etc/nixos#nixos";

      # ═══ 垃圾回收与优化（手动紧急清理，日常由 nix.gc.automatic 处理） ═══
      gc = "sudo nix-collect-garbage -d";
      optimise = "sudo nix-store --optimise";

      # ═══ Nix 工具 ═══
      generations = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      ns = "nix-shell";

      # ═══ Clash ═══
      start-clash = "sudo /etc/nixos/scripts/start-clash-tun.sh";
      stop-clash = "bash /etc/nixos/scripts/stop-clash.sh";

    };

    functions = {
      # 离线重建
      # --offline 来源：https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake.html
      rebuild-offline = ''
        sudo nixos-rebuild switch --flake /etc/nixos#nixos --offline
      '';

      # 更新 flake 锁文件并重建
      # nix flake update --flake 来源：https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake-update.html
      # /etc/nixos 已通过 tmpfiles.rules 授权给 zhangchongjie，无需 sudo
      rebuild-update = ''
        nix flake update --flake /etc/nixos && \
        sudo nixos-rebuild switch --flake /etc/nixos#nixos
      '';

      # 提交配置并重建（解决 "Git tree is dirty" 警告）
      # Flakes 只构建 Git 已追踪的文件，未提交的修改不会生效
      # 来源：https://nix.dev/manual/nix/stable/command-ref/new-cli/nix3-flake.html
      rebuild-commit = ''
        cd /etc/nixos && \
        git add -A && \
        git commit -m "chore: update config $(date +%Y%m%d-%H%M%S)" && \
        sudo nixos-rebuild switch --flake .#nixos
      '';
    };
  };
}
