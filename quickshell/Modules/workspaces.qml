import ".."
import QtQuick
import Quickshell.Hyprland

pragma ComponentBehavior: Bound;

Rectangle {
    id: root

    property var screen: null

    color: Theme.backgroundAlt
    radius: Theme.radius
    width: workspaceRow ? workspaceRow.width : 0
    height: workspaceRow ? workspaceRow.height : 0
    border.width: Theme.borderWidth
    border.color: Theme.primary

    Row {
        id: workspaceRow

        property bool isSpecialOpen: {
            const m = Hyprland.focusedMonitor;
            const sw = m && m.lastIpcObject ? m.lastIpcObject.specialWorkspace : null;
            return !!(sw && sw.name && sw.name !== "");
        }

        anchors.centerIn: parent
        spacing: 4

        Connections {
            function onRawEvent(ev) {
                if (ev.name === "activespecial" || ev.name === "focusedmon")
                    Hyprland.refreshMonitors();

            }

            target: Hyprland
        }

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: wsRect

                required property var modelData
                required property int index
                property var targetScreen: root.screen
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsRect.modelData.id

                // Visibility
                visible: wsRect.modelData.monitor && wsRect.modelData.monitor.name === wsRect.targetScreen.name && wsRect.modelData.id !== -98
                width: Theme.moduleWidth
                height: Theme.moduleHeight
                radius: Theme.radius
                border.width: Theme.borderWidth
                border.color: wsRect.isActive ? Theme.primary : "transparent"
                color: wsRect.isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : "transparent"
                scale: wsRect.isActive ? 1 : 0.8

                Text {
                    anchors.centerIn: parent
                    text: (workspaceRow.isSpecialOpen && wsRect.isActive) ? "" : wsRect.modelData.id
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: Font.Bold
                    color: wsRect.isActive ? Theme.foreground : Theme.foregroundAlt
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: wsRect.modelData.activate()
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                        easing.type: Easing.InOutQuad
                    }

                }

            }

        }

    }

}
