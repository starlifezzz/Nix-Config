# /etc/nixos/home/wezterm.nix
# WezTerm - 现代化终端模拟器（替代 Alacritty+Zellij）
{ config, pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    
    # 使用 Nix 管理 WezTerm 配置
    extraConfig = ''
      local wezterm = require 'wezterm'
      
      return {
        -- ═══════════════════════════════════════════════════════════
        -- 🎨 主题与外观
        -- ═══════════════════════════════════════════════════════════
        color_scheme = "Gruvbox Dark",
        font = wezterm.font "JetBrains Mono NL",
        font_size = 14.0,
        line_height = 1.2,
        
        -- 窗口背景透明度（毛玻璃效果）
        window_background_opacity = 0.95,
        text_background_opacity = 1.0,
        
        -- 启用连字字体
        harfbuzz_features = { "calt", "clig", "liga" },
        
        -- 光标样式
        default_cursor_style = "BlinkingBlock",
        cursor_blink_rate = 600,
        
        -- 选中文本的颜色
        selection_bg = "#ebdbb2",
        selection_fg = "#282828",
        
        -- ═══════════════════════════════════════════════════════════
        -- ⚡ 性能优化
        -- ═══════════════════════════════════════════════════════════
        -- 使用 WebGPU 后端（最新技术）
        front_end = "WebGpu",
        webgpu_power_preference = "HighPerformance",
        
        -- 抗锯齿
        antialias_custom_block_glyphs = true,
        freetype_load_flags = "FORCE_AUTOHINT | MONOCHROME",
        freetype_load_target = "Lcd",
        
        -- 滚动缓冲区（比 Zellij 更大）
        scrollback_lines = 50000,
        
        -- ═══════════════════════════════════════════════════════════
        -- 🖼️ 标签页与窗口
        -- ═══════════════════════════════════════════════════════════
        -- 启用漂亮的标签页栏
        enable_tab_bar = true,
        use_fancy_tab_bar = true,  -- 毛玻璃效果
        switch_to_last_active_tab_when_closing_tab = true,
        
        -- 窗口装饰（KDE 下使用服务端装饰）
        window_decorations = "RESERVED",
        window_padding = {
          left = 8,
          right = 8,
          top = 8,
          bottom = 8,
        },
        
        -- ═══════════════════════════════════════════════════════════
        -- 🔗 超级链接自动识别
        -- ═══════════════════════════════════════════════════════════
        hyperlink_rules = {
          {
            regex = [[\bhttps?://\S+\b]],
            format = "$0",
          },
          {
            regex = [[\bfile://\S+\b]],
            format = "$0",
          },
        },
        
        -- ═══════════════════════════════════════════════════════════
        -- 📋 智能文本选择
        -- ═══════════════════════════════════════════════════════════
        selection_word_boundary = [=[[\-{}:,;<>_\s!"#%&()+,./;<=>?@[\]^`{|}~]=] ,
        
        -- 鼠标选择自动复制到剪贴板
        automatically_reload_config = true,
        
        -- ═══════════════════════════════════════════════════════════
        -- ⌨️ 快捷键（类似 Zellij，但更强大）
        -- ═══════════════════════════════════════════════════════════
        disable_default_key_bindings = false,
        
        keys = {
          -- ────────────────────────────────────────────────────────
          -- 分屏管理（类似 Zellij Pane 模式）
          -- ────────────────────────────────────────────────────────
          {
            key = [[\]],
            mods = "CTRL",
            action = wezterm.action.TogglePaneZoomState,
          },
          {
            key = "s",
            mods = "CTRL",
            action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" },
          },
          {
            key = "d",
            mods = "CTRL",
            action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" },
          },
          {
            key = "x",
            mods = "CTRL",
            action = wezterm.action.CloseCurrentPane { confirm = false },
          },
          
          -- 分屏焦点切换（Vim 风格）
          {
            key = "h",
            mods = "CTRL",
            action = wezterm.action.ActivatePaneDirection "Left",
          },
          {
            key = "j",
            mods = "CTRL",
            action = wezterm.action.ActivatePaneDirection "Down",
          },
          {
            key = "k",
            mods = "CTRL",
            action = wezterm.action.ActivatePaneDirection "Up",
          },
          {
            key = "l",
            mods = "CTRL",
            action = wezterm.action.ActivatePaneDirection "Right",
          },
          
          -- 调整分屏大小
          {
            key = "H",
            mods = "CTRL",
            action = wezterm.action.AdjustPaneSize { "Left", 5 },
          },
          {
            key = "J",
            mods = "CTRL",
            action = wezterm.action.AdjustPaneSize { "Down", 5 },
          },
          {
            key = "K",
            mods = "CTRL",
            action = wezterm.action.AdjustPaneSize { "Up", 5 },
          },
          {
            key = "L",
            mods = "CTRL",
            action = wezterm.action.AdjustPaneSize { "Right", 5 },
          },
          
          -- ────────────────────────────────────────────────────────
          -- 标签页管理（类似 Zellij Tab 模式）
          -- ────────────────────────────────────────────────────────
          {
            key = "t",
            mods = "CTRL",
            action = wezterm.action.SpawnTab "CurrentPaneDomain",
          },
          {
            key = "w",
            mods = "CTRL",
            action = wezterm.action.CloseCurrentTab { confirm = false },
          },
          {
            key = "Tab",
            mods = "CTRL",
            action = wezterm.action.ActivateTabRelative (1),
          },
          {
            key = "Tab",
            mods = "CTRL|SHIFT",
            action = wezterm.action.ActivateTabRelative (-1),
          },
          
          -- 快速跳转到指定标签页
          {
            key = "1",
            mods = "ALT",
            action = wezterm.action.ActivateTab (0),
          },
          {
            key = "2",
            mods = "ALT",
            action = wezterm.action.ActivateTab (1),
          },
          {
            key = "3",
            mods = "ALT",
            action = wezterm.action.ActivateTab (2),
          },
          {
            key = "4",
            mods = "ALT",
            action = wezterm.action.ActivateTab (3),
          },
          {
            key = "5",
            mods = "ALT",
            action = wezterm.action.ActivateTab (4),
          },
          {
            key = "6",
            mods = "ALT",
            action = wezterm.action.ActivateTab (5),
          },
          {
            key = "7",
            mods = "ALT",
            action = wezterm.action.ActivateTab (6),
          },
          {
            key = "8",
            mods = "ALT",
            action = wezterm.action.ActivateTab (7),
          },
          {
            key = "9",
            mods = "ALT",
            action = wezterm.action.ActivateTab (8),
          },
          
          -- ────────────────────────────────────────────────────────
          -- 搜索与滚动
          -- ────────────────────────────────────────────────────────
          {
            key = "f",
            mods = "CTRL",
            action = wezterm.action.Search { CaseInSensitiveString = "" },
          },
          {
            key = "PageUp",
            mods = "SHIFT",
            action = wezterm.action.ScrollByPage (-1),
          },
          {
            key = "PageDown",
            mods = "SHIFT",
            action = wezterm.action.ScrollByPage (1),
          },
          {
            key = "UpArrow",
            mods = "SHIFT",
            action = wezterm.action.ScrollByLine (-1),
          },
          {
            key = "DownArrow",
            mods = "SHIFT",
            action = wezterm.action.ScrollByLine (1),
          },
          
          -- ────────────────────────────────────────────────────────
          -- 剪贴板操作
          -- ────────────────────────────────────────────────────────
          {
            key = "c",
            mods = "CTRL",
            action = wezterm.action.CopyTo "ClipboardAndPrimarySelection",
          },
          {
            key = "v",
            mods = "CTRL",
            action = wezterm.action.PasteFrom "Clipboard",
          },
          
          -- ────────────────────────────────────────────────────────
          -- 其他实用功能
          -- ────────────────────────────────────────────────────────
          {
            key = "Enter",
            mods = "CTRL|SHIFT",
            action = wezterm.action.ToggleFullScreen,
          },
          {
            key = ",",
            mods = "CTRL",
            action = wezterm.action.PromptInputLine {
              description = "Enter new name for tab",
              action = wezterm.action_callback(function(window, pane, line)
                if line then
                  window:active_tab():set_title(line)
                end
              end),
            },
          },
        },
        
        -- ═══════════════════════════════════════════════════════════
        -- 🎯 鼠标配置
        -- ═══════════════════════════════════════════════════════════
        mouse_bindings = {
          -- 中键粘贴
          {
            event = { Down = { streak = 1, button = "Middle" } },
            action = wezterm.action.PasteFrom "PrimarySelection",
          },
          -- 双击选择单词
          {
            event = { Down = { streak = 2, button = "Left" } },
            action = wezterm.action.SelectTextAtMouseCursor "Word",
          },
          -- 三行选择整行
          {
            event = { Down = { streak = 3, button = "Left" } },
            action = wezterm.action.SelectTextAtMouseCursor "Line",
          },
        },
        
        -- ═══════════════════════════════════════════════════════════
        -- 🔔 通知与警告
        -- ═══════════════════════════════════════════════════════════
        audible_bell = "Disabled",
        visual_bell = {
          fade_in_function = "EaseIn",
          fade_in_duration_ms = 150,
          fade_out_function = "EaseOut",
          fade_out_duration_ms = 150,
        },
        
        -- ═══════════════════════════════════════════════════════════
        -- 🐚 Shell 集成
        -- ═══════════════════════════════════════════════════════════
        default_prog = { "fish" },
        
        -- 启用 Fish Shell 集成
        unix_domains = {
          {
            name = "unix",
          },
        },
        
        -- 自动启动最后一个会话（类似 Zellij attach）
        automatic_reload_config = true,
      }
    '';
  };
  
  # 确保安装了 JetBrains Mono 字体
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    jetbrains-mono
    fira-code
  ];
}