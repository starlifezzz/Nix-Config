# /etc/nixos/home/zellij.nix
# Zellij Terminal Multiplexer 配置
{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;

    extraConfig = ''
      // 添加到配置中
      general {
        serialization_interval 60000          // 减少序列化频率（默认 10 秒 → 60 秒）
        serialize_pane_viewport false         // 禁用面板视口序列化，减少内存占用
        styled_underlines true                // 启用样式下划线（如果终端支持）
        support_kitty_keyboard_protocol true  // 启用 Kitty 键盘协议
      }

      theme "gruvbox-dark"  // Gruvbox 主题（暖色调）

      // 添加默认 Shell
      default_shell "fish"

      // 启用鼠标模式
      mouse_mode true

      // 自动复制到剪贴板
      copy_on_select true

      // ═══════════════════════════════════════════════════════════
      // 键盘快捷键配置
      // ═══════════════════════════════════════════════════════════
      keybinds clear-defaults=true {
        
        // ─────────────────────────────────────────────────────────
        // 锁定模式（防止误操作）
        // ─────────────────────────────────────────────────────────
        locked {
          // 解除锁定，返回普通模式
          bind "Ctrl g" { SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // 面板模式（管理面板布局）
        // ─────────────────────────────────────────────────────────
        pane {
          // 方向键移动焦点
          bind "left" { MoveFocus "left"; }
          bind "down" { MoveFocus "down"; }
          bind "up" { MoveFocus "up"; }
          bind "right" { MoveFocus "right"; }
          
          // Vim 风格移动焦点
          bind "h" { MoveFocus "left"; }
          bind "j" { MoveFocus "down"; }
          bind "k" { MoveFocus "up"; }
          bind "l" { MoveFocus "right"; }
          
          // 新建面板
          bind "n" { NewPane; SwitchToMode "normal"; }
          bind "d" { NewPane "down"; SwitchToMode "normal"; }   // 向下分割
          bind "r" { NewPane "right"; SwitchToMode "normal"; }  // 向右分割
          
          // 面板显示切换
          bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "normal"; }  // 切换嵌入/浮动
          bind "f" { ToggleFocusFullscreen; SwitchToMode "normal"; }      // 全屏切换
          bind "w" { ToggleFloatingPanes; SwitchToMode "normal"; }        // 浮动面板开关
          bind "z" { TogglePaneFrames; SwitchToMode "normal"; }           // 面板边框开关
          
          // 其他操作
          bind "p" { SwitchFocus; }                    // 切换焦点
          bind "c" { SwitchToMode "renamepane"; PaneNameInput 0; }  // 重命名面板
          bind "Ctrl p" { SwitchToMode "normal"; }     // 返回普通模式
        }

        // ─────────────────────────────────────────────────────────
        // 标签页模式
        // ─────────────────────────────────────────────────────────
        tab {
          // 切换标签页
          bind "left" { GoToPreviousTab; }
          bind "down" { GoToNextTab; }
          bind "up" { GoToPreviousTab; }
          bind "right" { GoToNextTab; }
          bind "h" { GoToPreviousTab; }
          bind "j" { GoToNextTab; }
          bind "k" { GoToPreviousTab; }
          bind "l" { GoToNextTab; }
          
          // 快速跳转到指定标签页 (1-9)
          bind "1" { GoToTab 1; SwitchToMode "normal"; }
          bind "2" { GoToTab 2; SwitchToMode "normal"; }
          bind "3" { GoToTab 3; SwitchToMode "normal"; }
          bind "4" { GoToTab 4; SwitchToMode "normal"; }
          bind "5" { GoToTab 5; SwitchToMode "normal"; }
          bind "6" { GoToTab 6; SwitchToMode "normal"; }
          bind "7" { GoToTab 7; SwitchToMode "normal"; }
          bind "8" { GoToTab 8; SwitchToMode "normal"; }
          bind "9" { GoToTab 9; SwitchToMode "normal"; }
          
          // 标签页管理
          bind "n" { NewTab; SwitchToMode "normal"; }              // 新建标签页
          bind "x" { CloseTab; SwitchToMode "normal"; }            // 关闭标签页
          bind "r" { SwitchToMode "renametab"; TabNameInput 0; }   // 重命名标签页
          bind "s" { ToggleActiveSyncTab; SwitchToMode "normal"; } // 同步标签页
          bind "tab" { ToggleTab; }                                // 切换标签
          
          // 面板拆分移动
          bind "[" { BreakPaneLeft; SwitchToMode "normal"; }   // 面板移到左边
          bind "]" { BreakPaneRight; SwitchToMode "normal"; }  // 面板移到右边
          bind "b" { BreakPane; SwitchToMode "normal"; }       // 分离面板
          
          // 返回普通模式
          bind "Ctrl t" { SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // 调整大小模式
        // ─────────────────────────────────────────────────────────
        resize {
          // 方向键调整大小
          bind "left" { Resize "Increase left"; }
          bind "down" { Resize "Increase down"; }
          bind "up" { Resize "Increase up"; }
          bind "right" { Resize "Increase right"; }
          
          // Vim 风格调整大小
          bind "h" { Resize "Increase left"; }
          bind "j" { Resize "Increase down"; }
          bind "k" { Resize "Increase up"; }
          bind "l" { Resize "Increase right"; }
          
          // 大写按键反向调整
          bind "H" { Resize "Decrease left"; }
          bind "J" { Resize "Decrease down"; }
          bind "K" { Resize "Decrease up"; }
          bind "L" { Resize "Decrease right"; }
          
          // 符号键调整
          bind "+" { Resize "Increase"; }
          bind "-" { Resize "Decrease"; }
          bind "=" { Resize "Increase"; }
          
          // 返回普通模式
          bind "Ctrl n" { SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // 移动模式（移动面板位置）
        // ─────────────────────────────────────────────────────────
        move {
          // 方向键移动面板
          bind "left" { MovePane "left"; }
          bind "down" { MovePane "down"; }
          bind "up" { MovePane "up"; }
          bind "right" { MovePane "right"; }
          
          // Vim 风格移动面板
          bind "h" { MovePane "left"; }
          bind "j" { MovePane "down"; }
          bind "k" { MovePane "up"; }
          bind "l" { MovePane "right"; }
          
          // 其他移动方式
          bind "n" { MovePane; }               // 开始移动
          bind "p" { MovePaneBackwards; }      // 向后移动
          bind "tab" { MovePane; }             // 开始移动（Tab 键）
          
          // 返回普通模式
          bind "Ctrl h" { SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // 滚动模式（查看历史输出）
        // ─────────────────────────────────────────────────────────
        scroll {
          // Alt+ 方向键移动焦点并退出
          bind "Alt left" { MoveFocusOrTab "left"; SwitchToMode "normal"; }
          bind "Alt down" { MoveFocus "down"; SwitchToMode "normal"; }
          bind "Alt up" { MoveFocus "up"; SwitchToMode "normal"; }
          bind "Alt right" { MoveFocusOrTab "right"; SwitchToMode "normal"; }
          bind "Alt h" { MoveFocusOrTab "left"; SwitchToMode "normal"; }
          bind "Alt j" { MoveFocus "down"; SwitchToMode "normal"; }
          bind "Alt k" { MoveFocus "up"; SwitchToMode "normal"; }
          bind "Alt l" { MoveFocusOrTab "right"; SwitchToMode "normal"; }
          
          // 翻页
          bind "PageUp" { PageScrollUp; }
          bind "PageDown" { PageScrollDown; }
          bind "left" { PageScrollUp; }
          bind "right" { PageScrollDown; }
          
          // Vim 风格滚动
          bind "h" { PageScrollUp; }
          bind "l" { PageScrollDown; }
          bind "u" { HalfPageScrollUp; }       // 向上半页
          bind "d" { HalfPageScrollDown; }     // 向下半页
          
          // Ctrl 组合键滚动
          bind "Ctrl b" { PageScrollUp; }      // 向上翻页 (backward)
          bind "Ctrl f" { PageScrollDown; }    // 向下翻页 (forward)
          bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }  // 滚动到底部并退出
          bind "Ctrl s" { SwitchToMode "normal"; }                  // 退出滚动模式
          
          // 上下滚动
          bind "up" { ScrollUp; }
          bind "down" { ScrollDown; }
          bind "j" { ScrollDown; }
          bind "k" { ScrollUp; }
          
          // 编辑回滚缓冲区
          bind "e" { EditScrollback; SwitchToMode "normal"; }
          
          // 搜索
          bind "s" { SwitchToMode "entersearch"; SearchInput 0; }
        }

        // ─────────────────────────────────────────────────────────
        // 搜索模式
        // ─────────────────────────────────────────────────────────
        search {
          bind "c" { SearchToggleOption "CaseSensitivity"; }  // 切换大小写敏感
          bind "o" { SearchToggleOption "WholeWord"; }        // 切换全字匹配
          bind "w" { SearchToggleOption "Wrap"; }             // 切换循环搜索
          bind "n" { Search "down"; }                         // 向下搜索
          bind "p" { Search "up"; }                           // 向上搜索
        }

        // ─────────────────────────────────────────────────────────
        // 会话模式（插件管理）
        // ─────────────────────────────────────────────────────────
        session {
          // 打开配置插件
          bind "c" {
            LaunchOrFocusPlugin "configuration" {
              floating true
              move_to_focused_tab true
            }
            SwitchToMode "normal"
          }
          
          // 打开插件管理器
          bind "p" {
            LaunchOrFocusPlugin "plugin-manager" {
              floating true
              move_to_focused_tab true
            }
            SwitchToMode "normal"
          }
          
          // 打开会话管理器
          bind "w" {
            LaunchOrFocusPlugin "session-manager" {
              floating true
              move_to_focused_tab true
            }
            SwitchToMode "normal"
          }
          
          // 返回普通模式
          bind "Ctrl o" { SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // Tmux 兼容模式
        // ─────────────────────────────────────────────────────────
        tmux {
          // 方向键移动焦点
          bind "left" { MoveFocus "left"; SwitchToMode "normal"; }
          bind "down" { MoveFocus "down"; SwitchToMode "normal"; }
          bind "up" { MoveFocus "up"; SwitchToMode "normal"; }
          bind "right" { MoveFocus "right"; SwitchToMode "normal"; }
          bind "h" { MoveFocus "left"; SwitchToMode "normal"; }
          bind "j" { MoveFocus "down"; SwitchToMode "normal"; }
          bind "k" { MoveFocus "up"; SwitchToMode "normal"; }
          bind "l" { MoveFocus "right"; SwitchToMode "normal"; }
          
          // Tmux 风格操作
          bind "space" { NextSwapLayout; }                      // 下一个布局
          bind "\"" { NewPane "down"; SwitchToMode "normal"; }  // 垂直分割
          bind "%" { NewPane "right"; SwitchToMode "normal"; }  // 水平分割
          bind "," { SwitchToMode "renametab"; }                // 重命名标签
          bind "[" { SwitchToMode "scroll"; }                   // 进入滚动模式
          bind "z" { ToggleFocusFullscreen; SwitchToMode "normal"; }  // 全屏切换
          
          // 标签页操作
          bind "c" { NewTab; SwitchToMode "normal"; }           // 新建标签
          bind "n" { GoToNextTab; SwitchToMode "normal"; }      // 下一个标签
          bind "p" { GoToPreviousTab; SwitchToMode "normal"; }  // 上一个标签
          bind "o" { FocusNextPane; }                           // 下一个焦点
          
          //  detach（断开会话）
          bind "d" { Detach; }
          
          // 发送 Ctrl+b 前缀
          bind "Ctrl b" { Write 2; SwitchToMode "normal"; }
          
          // 关闭面板
          bind "x" { CloseFocus; SwitchToMode "normal"; }
        }

        // ─────────────────────────────────────────────────────────
        // 共享快捷键（除了 locked 模式）
        // ─────────────────────────────────────────────────────────
        shared_except "locked" {
          // 调整大小
          bind "Alt +" { Resize "Increase"; }
          bind "Alt -" { Resize "Decrease"; }
          bind "Alt =" { Resize "Increase"; }
          
          // 布局切换
          bind "Alt [" { PreviousSwapLayout; }
          bind "Alt ]" { NextSwapLayout; }
          
          // 浮动面板
          bind "Alt f" { ToggleFloatingPanes; }
          
          // 模式切换
          bind "Ctrl g" { SwitchToMode "locked"; }    // 锁定模式
          bind "Alt i" { MoveTab "left"; }            // 向左移动标签
          bind "Alt o" { MoveTab "right"; }           // 向右移动标签
          
          // 面板操作
          bind "Alt n" { NewPane; }                   // 新建面板
          
          // 退出
          bind "Ctrl q" { Quit; }
        }

        // 进入移动模式
        shared_except "locked" "move" {
          bind "Ctrl h" { SwitchToMode "move"; }
        }

        // 进入会话模式
        shared_except "locked" "session" {
          bind "Ctrl o" { SwitchToMode "session"; }
        }

        // 滚动模式下的焦点移动（不退出滚动模式）
        shared_except "locked" "scroll" {
          bind "Alt left" { MoveFocusOrTab "left"; }
          bind "Alt down" { MoveFocus "down"; }
          bind "Alt up" { MoveFocus "up"; }
          bind "Alt right" { MoveFocusOrTab "right"; }
          bind "Alt h" { MoveFocusOrTab "left"; }
          bind "Alt j" { MoveFocus "down"; }
          bind "Alt k" { MoveFocus "up"; }
          bind "Alt l" { MoveFocusOrTab "right"; }
        }

        // 进入 Tmux 模式
        shared_except "locked" "scroll" "search" "tmux" {
          bind "Ctrl b" { SwitchToMode "tmux"; }
        }

        // 进入滚动模式
        shared_except "locked" "scroll" "search" {
          bind "Ctrl s" { SwitchToMode "scroll"; }
        }

        // 进入标签页模式
        shared_except "locked" "tab" {
          bind "Ctrl t" { SwitchToMode "tab"; }
        }

        // 进入面板模式
        shared_except "locked" "pane" {
          bind "Ctrl p" { SwitchToMode "pane"; }
        }

        // 进入调整大小模式
        shared_except "locked" "resize" {
          bind "Ctrl n" { SwitchToMode "resize"; }
        }

        // 回车键返回普通模式
        shared_except "normal" "locked" "entersearch" {
          bind "enter" { SwitchToMode "normal"; }
        }

        // ESC 键返回普通模式
        shared_except "normal" "locked" "entersearch" "renametab" "renamepane" {
          bind "esc" { SwitchToMode "normal"; }
        }

        // 在面板和 Tmux 模式中关闭焦点
        shared_among "pane" "tmux" {
          bind "x" { CloseFocus; SwitchToMode "normal"; }
        }

        // 滚动和搜索模式共享的快捷键
        shared_among "scroll" "search" {
          bind "PageDown" { PageScrollDown; }
          bind "PageUp" { PageScrollUp; }
          bind "left" { PageScrollUp; }
          bind "down" { ScrollDown; }
          bind "up" { ScrollUp; }
          bind "right" { PageScrollDown; }
          bind "Ctrl b" { PageScrollUp; }
          bind "Ctrl c" { ScrollToBottom; SwitchToMode "normal"; }
          bind "d" { HalfPageScrollDown; }
          bind "Ctrl f" { PageScrollDown; }
          bind "h" { PageScrollUp; }
          bind "j" { ScrollDown; }
          bind "k" { ScrollUp; }
          bind "l" { PageScrollDown; }
          bind "Ctrl s" { SwitchToMode "normal"; }
          bind "u" { HalfPageScrollUp; }
        }

        // 进入搜索模式
        entersearch {
          bind "Ctrl c" { SwitchToMode "scroll"; }
          bind "esc" { SwitchToMode "scroll"; }
          bind "enter" { SwitchToMode "search"; }
        }

        // 重命名标签页
        renametab {
          bind "esc" { UndoRenameTab; SwitchToMode "tab"; }
        }

        // 重命名模式共享快捷键
        shared_among "renametab" "renamepane" {
          bind "Ctrl c" { SwitchToMode "normal"; }
        }

        // 重命名面板
        renamepane {
          bind "esc" { UndoRenamePane; SwitchToMode "pane"; }
        }

        // 会话和 Tmux 模式共享的 detach
        shared_among "session" "tmux" {
          bind "d" { Detach; }
        }
      }

      // ═══════════════════════════════════════════════════════════
      // 插件配置
      // ═══════════════════════════════════════════════════════════
      plugins {
        about location="zellij:about"
        compact-bar location="zellij:compact-bar"
        configuration location="zellij:configuration"
        filepicker location="zellij:strider" {
          cwd "/"
        }
        plugin-manager location="zellij:plugin-manager"
        session-manager location="zellij:session-manager"
        status-bar location="zellij:status-bar"
        strider location="zellij:strider"
        tab-bar location="zellij:tab-bar"
        welcome-screen location="zellij:session-manager" {
          welcome_screen true
        }
      }

      // 后台加载插件（不阻塞启动）
      load_plugins {
      }

      // 禁用启动提示
      show_startup_tips false
    '';
  };
}
