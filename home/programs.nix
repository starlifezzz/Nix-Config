# /etc/nixos/home/programs.nix
# programs.nix - 仅作为导入索引，实际配置已拆分到独立文件
# 所有 programs.x 形式的配置现在按应用拆分到独立文件中

imports = [
  ./programs/fish.nix      # Fish Shell 配置
  ./programs/git.nix       # Git 版本控制配置
  ./programs/alacritty.nix # Alacritty 终端模拟器配置
  ./programs/zellij.nix    # Zellij Terminal Multiplexer 配置
  ./programs/direnv.nix    # Direnv 开发环境配置
  ./programs/vscode.nix    # VSCode 代码编辑器配置
  ./programs/vim.nix       # Vim 文本编辑器配置
];
