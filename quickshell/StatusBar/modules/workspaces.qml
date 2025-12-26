import "../.."
import QtQuick
import Quickshell.Hyprland

Row {
    id: workspaceModule

    property var screen: null

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            // hyprland binding
            property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

            visible: modelData.monitor && modelData.monitor.name === workspaceModule.screen.name && modelData.id != -98
            width: 40
            height: 40
            radius: Theme.radius
            color: isActive ? Theme.primary : "transparent"

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.family: Theme.fontMain
                font.pixelSize: 15
                font.weight: 700
                color: isActive ? Theme.backgroundSolid : Theme.foregroundAlt
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
