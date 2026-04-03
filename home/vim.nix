# /etc/nixos/home/vim.nix
# Vim 文本编辑器配置
{ config, pkgs, lib, ... }:

{
  programs.vim = {
    enable = true;
    
    # 基础设置
    settings = {
      number = true;          # 显示行号
      relativenumber = true;  # 相对行号
      wrap = false;           # 不换行
      cursorline = true;      # 高亮当前行
      shiftwidth = 2;         # 缩进宽度
      tabstop = 2;            # Tab 宽度
      expandtab = true;       # Tab 转空格
      ignorecase = true;      # 忽略大小写
      smartcase = true;       # 智能大小写
      hlsearch = true;        # 高亮搜索结果
      incsearch = true;       # 增量搜索
      showmode = true;        # 显示当前模式
      ruler = true;           # 显示标尺
      backspace = "indent,eol,start";  # Backspace 行为
    };
    
    # 额外配置
    extraConfig = ''
      " 基本映射
      nnoremap <C-s> :w<CR>
      nnoremap <C-q> :q!<CR>
      nnoremap <Esc> :nohlsearch<CR>
      
      " 窗口导航
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l
      
      " 更好的行移动
      nnoremap J mzJ`z
      nnoremap <C-j> <C-e>
      nnoremap <C-k> <C-y>
      
      " 重新选择缩进
      vnoremap < <gv
      vnoremap > >gv
    '';
    
    # 插件配置（可选）
    # plugins = with pkgs.vimPlugins; [
    #   # 示例：常用插件
    #   # vim-nix  # Nix 语法支持
    # ];
  };
}
