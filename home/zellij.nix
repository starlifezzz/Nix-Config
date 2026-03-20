{ config, pkgs, lib, ... }:

{
  programs.zellij = {
    enable = true;

    settings = {
      general = {
        default_mode = "normal";
        mouse_mode = true;
        pane_frames = true;
        scroll_buffer_size = 10000;
        copy_on_select = true;
        show_startup_tips = false;
        auto_layout = true;
        session_serialization = true;
        serialize_pane_viewport = false;
        scrollback_lines_to_serialize = 10000;
        styled_underlines = true;
        serialization_interval = 10000;
        disable_session_metadata = false;
        support_kitty_keyboard_protocol = true;
        stacked_resize = true;
        copy_clipboard = "system";
        on_force_close = "detach";
      };

      keybinds = {
        normal = [
          { keys = [ "Alt +"]; action = "Resize Increase"; }
          { keys = [ "Alt -"]; action = "Resize Decrease"; }
          { keys = [ "Alt ="]; action = "Resize Increase"; }
          { keys = [ "Alt [" ]; action = "PreviousSwapLayout"; }
          { keys = [ "Alt ]" ]; action = "NextSwapLayout"; }
          { keys = [ "Alt f" ]; action = "ToggleFloatingPanes"; }
          { keys = [ "Ctrl g" ]; action = "SwitchToMode locked"; }
          { keys = [ "Alt i" ]; action = "MoveTab left"; }
          { keys = [ "Alt n" ]; action = "NewPane"; }
          { keys = [ "Alt o" ]; action = "MoveTab right"; }
          { keys = [ "Ctrl q" ]; action = "Quit"; }
          { keys = [ "Ctrl h" ]; action = "SwitchToMode move"; }
          { keys = [ "Ctrl o" ]; action = "SwitchToMode session"; }
          { keys = [ "Alt Left" ]; action = "MoveFocusOrTab left"; }
          { keys = [ "Alt Down" ]; action = "MoveFocus down"; }
          { keys = [ "Alt Up" ]; action = "MoveFocus up"; }
          { keys = [ "Alt Right" ]; action = "MoveFocusOrTab right"; }
          { keys = [ "Alt h" ]; action = "MoveFocusOrTab left"; }
          { keys = [ "Alt j" ]; action = "MoveFocus down"; }
          { keys = [ "Alt k" ]; action = "MoveFocus up"; }
          { keys = [ "Alt l" ]; action = "MoveFocusOrTab right"; }
          { keys = [ "Ctrl b" ]; action = "SwitchToMode tmux"; }
          { keys = [ "Ctrl s" ]; action = "SwitchToMode scroll"; }
          { keys = [ "Ctrl t" ]; action = "SwitchToMode tab"; }
          { keys = [ "Ctrl p" ]; action = "SwitchToMode pane"; }
          { keys = [ "Ctrl n" ]; action = "SwitchToMode resize"; }
        ];

        locked = [
          { keys = [ "Ctrl g" ]; action = "SwitchToMode normal"; }
        ];

        pane = [
          { keys = [ "Left" ]; action = "MoveFocus left"; }
          { keys = [ "Down" ]; action = "MoveFocus down"; }
          { keys = [ "Up" ]; action = "MoveFocus up"; }
          { keys = [ "Right" ]; action = "MoveFocus right"; }
          { keys = [ "c" ]; action = "SwitchToMode renamepane"; PaneNameInput = 0; }
          { keys = [ "d" ]; action = [ "NewPane down" "SwitchToMode normal" ]; }
          { keys = [ "e" ]; action = [ "TogglePaneEmbedOrFloating" "SwitchToMode normal" ]; }
          { keys = [ "f" ]; action = [ "ToggleFocusFullscreen" "SwitchToMode normal" ]; }
          { keys = [ "h" ]; action = "MoveFocus left"; }
          { keys = [ "j" ]; action = "MoveFocus down"; }
          { keys = [ "k" ]; action = "MoveFocus up"; }
          { keys = [ "l" ]; action = "MoveFocus right"; }
          { keys = [ "n" ]; action = [ "NewPane" "SwitchToMode normal" ]; }
          { keys = [ "p" ]; action = "SwitchFocus"; }
          { keys = [ "Ctrl p" ]; action = "SwitchToMode normal"; }
          { keys = [ "r" ]; action = [ "NewPane right" "SwitchToMode normal" ]; }
          { keys = [ "w" ]; action = [ "ToggleFloatingPanes" "SwitchToMode normal" ]; }
          { keys = [ "z" ]; action = [ "TogglePaneFrames" "SwitchToMode normal" ]; }
        ];

        tab = [
          { keys = [ "Left" ]; action = "GoToPreviousTab"; }
          { keys = [ "Down" ]; action = "GoToNextTab"; }
          { keys = [ "Up" ]; action = "GoToPreviousTab"; }
          { keys = [ "Right" ]; action = "GoToNextTab"; }
          { keys = [ "1" ]; action = [ "GoToTab 1" "SwitchToMode normal" ]; }
          { keys = [ "2" ]; action = [ "GoToTab 2" "SwitchToMode normal" ]; }
          { keys = [ "3" ]; action = [ "GoToTab 3" "SwitchToMode normal" ]; }
          { keys = [ "4" ]; action = [ "GoToTab 4" "SwitchToMode normal" ]; }
          { keys = [ "5" ]; action = [ "GoToTab 5" "SwitchToMode normal" ]; }
          { keys = [ "6" ]; action = [ "GoToTab 6" "SwitchToMode normal" ]; }
          { keys = [ "7" ]; action = [ "GoToTab 7" "SwitchToMode normal" ]; }
          { keys = [ "8" ]; action = [ "GoToTab 8" "SwitchToMode normal" ]; }
          { keys = [ "9" ]; action = [ "GoToTab 9" "SwitchToMode normal" ]; }
          { keys = [ "[" ]; action = [ "BreakPaneLeft" "SwitchToMode normal" ]; }
          { keys = [ "]" ]; action = [ "BreakPaneRight" "SwitchToMode normal" ]; }
          { keys = [ "b" ]; action = [ "BreakPane" "SwitchToMode normal" ]; }
          { keys = [ "h" ]; action = "GoToPreviousTab"; }
          { keys = [ "j" ]; action = "GoToNextTab"; }
          { keys = [ "k" ]; action = "GoToPreviousTab"; }
          { keys = [ "l" ]; action = "GoToNextTab"; }
          { keys = [ "n" ]; action = [ "NewTab" "SwitchToMode normal" ]; }
          { keys = [ "r" ]; action = "SwitchToMode renametab"; TabNameInput = 0; }
          { keys = [ "s" ]; action = [ "ToggleActiveSyncTab" "SwitchToMode normal" ]; }
          { keys = [ "Ctrl t" ]; action = "SwitchToMode normal"; }
          { keys = [ "x" ]; action = [ "CloseTab" "SwitchToMode normal" ]; }
          { keys = [ "Tab" ]; action = "ToggleTab"; }
        ];

        resize = [
          { keys = [ "Left" ]; action = "Resize Increase left"; }
          { keys = [ "Down" ]; action = "Resize Increase down"; }
          { keys = [ "Up" ]; action = "Resize Increase up"; }
          { keys = [ "Right" ]; action = "Resize Increase right"; }
          { keys = [ "+" ]; action = "Resize Increase"; }
          { keys = [ "-" ]; action = "Resize Decrease"; }
          { keys = [ "=" ]; action = "Resize Increase"; }
          { keys = [ "H" ]; action = "Resize Decrease left"; }
          { keys = [ "J" ]; action = "Resize Decrease down"; }
          { keys = [ "K" ]; action = "Resize Decrease up"; }
          { keys = [ "L" ]; action = "Resize Decrease right"; }
          { keys = [ "h" ]; action = "Resize Increase left"; }
          { keys = [ "j" ]; action = "Resize Increase down"; }
          { keys = [ "k" ]; action = "Resize Increase up"; }
          { keys = [ "l" ]; action = "Resize Increase right"; }
          { keys = [ "Ctrl n" ]; action = "SwitchToMode normal"; }
        ];

        move = [
          { keys = [ "Left" ]; action = "MovePane left"; }
          { keys = [ "Down" ]; action = "MovePane down"; }
          { keys = [ "Up" ]; action = "MovePane up"; }
          { keys = [ "Right" ]; action = "MovePane right"; }
          { keys = [ "h" ]; action = "MovePane left"; }
          { keys = [ "Ctrl h" ]; action = "SwitchToMode normal"; }
          { keys = [ "j" ]; action = "MovePane down"; }
          { keys = [ "k" ]; action = "MovePane up"; }
          { keys = [ "l" ]; action = "MovePane right"; }
          { keys = [ "n" ]; action = "MovePane"; }
          { keys = [ "p" ]; action = "MovePaneBackwards"; }
          { keys = [ "Tab" ]; action = "MovePane"; }
        ];

        scroll = [
          { keys = [ "Alt Left" ]; action = [ "MoveFocusOrTab left" "SwitchToMode normal" ]; }
          { keys = [ "Alt Down" ]; action = [ "MoveFocus down" "SwitchToMode normal" ]; }
          { keys = [ "Alt Up" ]; action = [ "MoveFocus up" "SwitchToMode normal" ]; }
          { keys = [ "Alt Right" ]; action = [ "MoveFocusOrTab right" "SwitchToMode normal" ]; }
          { keys = [ "e" ]; action = [ "EditScrollback" "SwitchToMode normal" ]; }
          { keys = [ "Alt h" ]; action = [ "MoveFocusOrTab left" "SwitchToMode normal" ]; }
          { keys = [ "Alt j" ]; action = [ "MoveFocus down" "SwitchToMode normal" ]; }
          { keys = [ "Alt k" ]; action = [ "MoveFocus up" "SwitchToMode normal" ]; }
          { keys = [ "Alt l" ]; action = [ "MoveFocusOrTab right" "SwitchToMode normal" ]; }
          { keys = [ "s" ]; action = "SwitchToMode entersearch"; SearchInput = 0; }
          { keys = [ "PageDown" ]; action = "PageScrollDown"; }
          { keys = [ "PageUp" ]; action = "PageScrollUp"; }
          { keys = [ "Ctrl b" ]; action = "PageScrollUp"; }
          { keys = [ "Ctrl c" ]; action = [ "ScrollToBottom" "SwitchToMode normal" ]; }
          { keys = [ "d" ]; action = "HalfPageScrollDown"; }
          { keys = [ "Ctrl f" ]; action = "PageScrollDown"; }
          { keys = [ "u" ]; action = "HalfPageScrollUp"; }
        ];

        search = [
          { keys = [ "c" ]; action = "SearchToggleOption CaseSensitivity"; }
          { keys = [ "n" ]; action = "Search down"; }
          { keys = [ "o" ]; action = "SearchToggleOption WholeWord"; }
          { keys = [ "p" ]; action = "Search up"; }
          { keys = [ "w" ]; action = "SearchToggleOption Wrap"; }
        ];

        session = [
          { keys = [ "c" ]; action = [
              { LaunchOrFocusPlugin = "configuration"; floating = true; move_to_focused_tab = true; }
              "SwitchToMode normal"
            ];
          };
          { keys = [ "Ctrl o" ]; action = "SwitchToMode normal"; }
          { keys = [ "p" ]; action = [
              { LaunchOrFocusPlugin = "plugin-manager"; floating = true; move_to_focused_tab = true; }
              "SwitchToMode normal"
            ];
          };
          { keys = [ "w" ]; action = [
              { LaunchOrFocusPlugin = "session-manager"; floating = true; move_to_focused_tab = true; }
              "SwitchToMode normal"
            ];
          };
        ];

        entersearch = [
          { keys = [ "Ctrl c" ]; action = "SwitchToMode scroll"; }
          { keys = [ "esc" ]; action = "SwitchToMode scroll"; }
          { keys = [ "enter" ]; action = "SwitchToMode search"; }
        ];

        renametab = [
          { keys = [ "esc" ]; action = [ "UndoRenameTab" "SwitchToMode tab" ]; }
          { keys = [ "Ctrl c" ]; action = "SwitchToMode normal"; }
        ];

        renamepane = [
          { keys = [ "esc" ]; action = [ "UndoRenamePane" "SwitchToMode pane" ]; }
          { keys = [ "Ctrl c" ]; action = "SwitchToMode normal"; }
        ];

        tmux = [
          { keys = [ "Left" ]; action = [ "MoveFocus left" "SwitchToMode normal" ]; }
          { keys = [ "Down" ]; action = [ "MoveFocus down" "SwitchToMode normal" ]; }
          { keys = [ "Up" ]; action = [ "MoveFocus up" "SwitchToMode normal" ]; }
          { keys = [ "Right" ]; action = [ "MoveFocus right" "SwitchToMode normal" ]; }
          { keys = [ "space" ]; action = "NextSwapLayout"; }
          { keys = [ "\"" ]; action = [ "NewPane down" "SwitchToMode normal" ]; }
          { keys = [ "%" ]; action = [ "NewPane right" "SwitchToMode normal" ]; }
          { keys = [ "," ]; action = "SwitchToMode renametab"; }
          { keys = [ "[" ]; action = "SwitchToMode scroll"; }
          { keys = [ "Ctrl b" ]; action = [ "Write 2" "SwitchToMode normal" ]; }
          { keys = [ "c" ]; action = [ "NewTab" "SwitchToMode normal" ]; }
          { keys = [ "h" ]; action = [ "MoveFocus left" "SwitchToMode normal" ]; }
          { keys = [ "j" ]; action = [ "MoveFocus down" "SwitchToMode normal" ]; }
          { keys = [ "k" ]; action = [ "MoveFocus up" "SwitchToMode normal" ]; }
          { keys = [ "l" ]; action = [ "MoveFocus right" "SwitchToMode normal" ]; }
          { keys = [ "n" ]; action = [ "GoToNextTab" "SwitchToMode normal" ]; }
          { keys = [ "o" ]; action = "FocusNextPane"; }
          { keys = [ "p" ]; action = [ "GoToPreviousTab" "SwitchToMode normal" ]; }
          { keys = [ "z" ]; action = [ "ToggleFocusFullscreen" "SwitchToMode normal" ]; }
          { keys = [ "x" ]; action = [ "CloseFocus" "SwitchToMode normal" ]; }
          { keys = [ "d" ]; action = "Detach"; }
        ];
      };

      plugins = {
        about = {
          location = "zellij:about";
        };
        compact-bar = {
          location = "zellij:compact-bar";
        };
        configuration = {
          location = "zellij:configuration";
        };
        filepicker = {
          location = "zellij:strider";
          cwd = "/";
        };
        plugin-manager = {
          location = "zellij:plugin-manager";
        };
        session-manager = {
          location = "zellij:session-manager";
        };
        status-bar = {
          location = "zellij:status-bar";
        };
        strider = {
          location = "zellij:strider";
        };
        tab-bar = {
          location = "zellij:tab-bar";
        };
        welcome-screen = {
          location = "zellij:session-manager";
          welcome_screen = true;
        };
      };

      load_plugins = [];
    };
  };
}