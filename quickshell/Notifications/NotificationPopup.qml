import ".."
import QtQml
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    property var notifications: NotificationService.notifications
    property var cards: []

    screen: Quickshell.screens[0]
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 200
    implicitHeight: 700
    visible: cards.length > 0

    anchors {
        top: true
        right: true
    }

    Connections {
        function onNotificationsChanged() {
            if (notifications.length > cards.length)
                cards = notifications.slice();
            else
                cards = notifications.slice();
        }

        target: NotificationService
    }

    Column {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.gap
        anchors.rightMargin: Theme.gap
        spacing: 12

        Repeater {
            model: notifications

            delegate: Rectangle {
                required property var modelData
                readonly property var notif: modelData

                width: 180
                implicitHeight: 100
                radius: Theme.radius
                color: Theme.background
                border.color: Theme.primary
                border.width: Theme.borderWidth

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

}
