import "../.."
import QtQuick
import Quickshell.Hyprland

Row {
    id: workspaceModule

    property string screenName: ""

    spacing: 4

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            property bool isActive: Hyprland.focusedWorkspace.id === modelData.id

            visible: modelData.monitor && modelData.monitor.name === workspaceModule.screenName
            width: 30
            height: 30
            radius: 15
            color: isActive ? Theme.primary : "transparent"

            Text {
                anchors.centerIn: parent
                text: modelData.id
                font.family: Theme.fontMono
                font.pixelSize: 14
                font.weight: Font.Bold
                color: isActive ? Theme.background : Theme.textPrimary
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch("workspace", modelData.id);
                }
            }

        }

    }

}
