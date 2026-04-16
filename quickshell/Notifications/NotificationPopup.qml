import ".."
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    screen: Quickshell.screens[1]
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 200
    implicitHeight: 700
    visible: NotificationService.notifications

    anchors {
        top: true
        right: true
    }

    Repeater {
        model: NotificationService.notifications

        delegate: Rectangle {
            required property Notification modelData
            readonly property Notification notif: modelData

            width: 180
            implicitHeight: 100
            radius: Theme.radius
            color: Theme.background
            border.color: Theme.primary
            border.width: 3
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 20
            anchors.rightMargin: 20

            Column {
                anchors.fill: parent
                anchors.margins: 10

                Text {
                    text: notif.summary
                    color: Theme.foreground
                }

                Text {
                    text: notif.body
                    color: Theme.foreground
                }

            }

        }

    }

}
