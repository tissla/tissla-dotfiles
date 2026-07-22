import ".."
import QtQuick

pragma ComponentBehavior: Bound;
Rectangle {
    id: root

    property var screen: null

    color: Theme.mantle
    radius: Theme.radius
    width: workspaceRow ? workspaceRow.width : 0
    height: workspaceRow ? workspaceRow.height : 0
    border.width: Theme.borderWidth
    border.color: Theme.accent

    Row {
        id: workspaceRow

        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: root.screen ? WorkspaceProvider.workspaces.filter((ws) => ws.monitor === root.screen.name) : []

            delegate: Rectangle {
                id: wsRect

                required property var modelData

                width: Theme.moduleWidth
                height: Theme.moduleHeight
                radius: Theme.radius
                border.width: Theme.borderWidth
                border.color: wsRect.modelData.active ? Theme.accent : "transparent"
                color: wsRect.modelData.active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1) : "transparent"
                scale: wsRect.modelData.active ? 1 : 0.8

                Text {
                    anchors.centerIn: parent
                    text: wsRect.modelData.special ? "" : wsRect.modelData.idx
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeBase
                    font.weight: Font.Bold
                    color: wsRect.modelData.active ? Theme.text : Theme.subtext1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: WorkspaceProvider.activate(wsRect.modelData.id)
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
