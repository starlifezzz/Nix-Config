# /etc/nixos/home/vim.nix
# Vim 文本编辑器配置
{ config, pkgs, lib, ... }:

{
  programs.vim = {
    enable = true;
    
    # 所有配置都通过 extraConfig 完成
    extraConfig = ''
      " 基本设置
      set number                  " 显示行号
      set relativenumber          " 相对行号
      set nowrap                  " 不换行
      set cursorline              " 高亮当前行
      set shiftwidth=2            " 缩进宽度
      set tabstop=2               " Tab 宽度
      set expandtab               " Tab 转空格
      set ignorecase              " 忽略大小写
      set smartcase               " 智能大小写
      set hlsearch                " 高亮搜索结果
      set incsearch               " 增量搜索
      set showmode                " 显示当前模式
      set ruler                   " 显示标尺
      set backspace=indent,eol,start
      
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
