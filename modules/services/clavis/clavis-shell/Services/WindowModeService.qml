pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common

// 窗口模式服务：平铺/浮动切换
// 持久化: ~/.config/clavis/window-mode.json
// 切换: 写/删 ~/.config/niri/clavis/floating.kdl + niri msg action load-config-file
Singleton {
    id: root

    readonly property string configDir: Paths.configHome
    readonly property string statePath: configDir + "/window-mode.json"
    readonly property string floatingConfigPath: Paths.xdgConfigHome + "/niri/clavis/floating.kdl"
    readonly property string scriptPath: Paths.scriptPath("system", "write_niri_floating_config.sh")

    property bool storeReady: false
    property bool floating: true // 默认浮动（KDE/COSMIC 式堆叠）

    function applyMode() {
        applyProcess.command = [
            "bash", root.scriptPath,
            root.floating ? "true" : "false",
            root.floatingConfigPath,
            "niri"
        ];
        applyProcess.running = false;
        applyProcess.running = true;
    }

    function toggle() {
        root.floating = !root.floating;
        root.save();
        root.applyMode();
    }

    function save() {
        if (!root.storeReady)
            return;
        stateFile.setText(JSON.stringify({
            "floating": root.floating
        }, null, 2));
    }

    Process {
        id: applyProcess
    }

    Process {
        id: ensureStoreDir

        command: [ "mkdir", "-p", root.configDir ]
        running: true
        onExited: {
            root.storeReady = true;
            stateFile.reload();
        }
    }

    FileView {
        id: stateFile

        path: root.statePath

        onLoaded: {
            try {
                const parsed = JSON.parse(stateFile.text().trim() || "{}");
                if (typeof parsed.floating === "boolean")
                    root.floating = parsed.floating;
            } catch (error) {
                // 保持默认
            }
            // 启动时确保 floating.kdl 与持久化模式一致
            Qt.callLater(root.applyMode);
        }

        onLoadFailed: {
            root.save();
            Qt.callLater(root.applyMode);
        }
    }
}