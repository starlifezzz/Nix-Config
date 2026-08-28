import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets.common

// 剪贴板历史按钮：点击打开 Spotlight 剪贴板历史
BarCircularButton {
    id: root

    property var screen: null

    iconName: "content_copy"
    containerColor: Appearance.colors.colPrimaryContainer
    rippleColor: Appearance.colors.colOnPrimaryContainer
    iconColor: Appearance.colors.colOnPrimaryContainer
    tooltipText: qsTr("剪贴板历史")
    onClicked: Quickshell.execDetached([
        "key", "ipc", "call", "spotlight", "openMode", "clipboard"
    ])
}
