# /etc/nixos/home/vim.nix
# Vim 文本编辑器配置
{ config, pkgs, lib, ... }:

{
  programs.vim = {
    enable = true;
    
    # 基础设置 - 仅保留 Home Manager 确认支持的选项
    settings = {
      number = true;          # 显示行号
      relativenumber = true;  # 相对行号
    };
    
    # 额外配置 - 所有其他 Vim 设置
    extraConfig = ''
      " Backspace 行为
      set backspace=indent,eol,start
      
      " 高亮当前行
      set cursorline
      
      " 显示模式
      set showmode
      
      " 搜索设置
      set ignorecase          " 忽略大小写
      set smartcase           " 智能大小写
      set hlsearch            " 高亮搜索结果
      set incsearch           " 增量搜索
      
      " 不换行
      set nowrap
      
      " 缩进设置
      set shiftwidth=2        " 缩进宽度
      set tabstop=2           " Tab 宽度
      set expandtab           " Tab 转空格
      
      " 显示标尺
      set ruler
      
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
