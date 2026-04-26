import ".."
import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    property var notifications: NotificationService.notifications
    property var cards: []

    screen: Quickshell.screens[0]
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 300
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

                width: 280
                implicitHeight: 140
                radius: Theme.radius
                color: Theme.background
                border.color: Theme.primary
                border.width: Theme.borderWidth

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    ColumnLayout {
                        // A
                        Text {
                            text: notif.summary
                            color: Theme.foreground
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: 16
                            width: 130
                            elide: Text.ElideRight
                        }

                        // B
                        Text {
                            text: notif.appName
                            color: Theme.foreground
                            font.weight: Font.Bold
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignRight
                            width: 130
                        }

                    }

                    ColumnLayout {
                        // C
                        Image {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            source: notif.image
                        }

                        // D
                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.alignment: Qt.AlignTop
                            text: notif.body
                            wrapMode: Text.Wrap
                            color: Theme.foreground
                        }

                    }

                }

            }

        }

    }

}
