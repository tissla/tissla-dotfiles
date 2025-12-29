import "../.."
import QtQuick
import Quickshell.Hyprland

Rectangle {
    id: root

    property var screen: null

    color: Theme.backgroundAlt
    radius: Theme.radius
    width: workspaceModule ? workspaceModule.width : 0
    height: workspaceModule ? workspaceModule.height : 0
    border.width: 3
    border.color: Theme.primary

    Row {
        id: workspaceModule

        property var screen: parent.screen

        anchors.margins: root.border.width
        anchors.centerIn: parent

        Repeater {
            model: Hyprland.workspaces

            Rectangle {
                // hyprland binding
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

                visible: modelData.monitor && modelData.monitor.name === workspaceModule.screen.name && modelData.id != -98
                width: 40
                height: 40
                radius: Theme.radius
                border.width: 3
                border.color: isActive ? Theme.primary : "transparent"
                color: isActive ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3) : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: modelData.id
                    font.family: Theme.fontMain
                    font.pixelSize: 15
                    font.weight: 700
                    color: isActive ? Theme.foreground : Theme.foregroundAlt
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        modelData.activate();
                    }
                }

            }

        }

    }

}
