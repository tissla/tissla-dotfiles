import ".."
import QtQml
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

PanelWindow {
    id: root

    property var notifications: NotificationService.notifications

    screen: Quickshell.screens[0]
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 300
    implicitHeight: 700
    visible: notifications.length > 0

    anchors {
        top: true
        right: true
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
                color: Theme.baseSolid
                border.color: Theme.accent
                border.width: Theme.borderWidth

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15

                    RowLayout {
                        // A
                        Text {
                            text: notif.summary
                            color: Theme.text
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignLeft
                            font.pixelSize: 16
                            Layout.preferredWidth: 130
                            elide: Text.ElideRight
                        }

                        // B
                        Text {
                            text: notif.appName
                            color: Theme.text
                            font.weight: Font.Bold
                            font.pixelSize: 18
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }

                    }

                    RowLayout {
                        // C
                        Image {
                            Layout.preferredWidth: 50
                            Layout.preferredHeight: 50
                            source: notif.image
                        }

                        // D
                        Text {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            Layout.maximumHeight: 100
                            Layout.alignment: Qt.AlignTop
                            text: notif.body
                            Layout.leftMargin: 10
                            wrapMode: Text.Wrap
                            color: Theme.text
                        }

                    }

                }

            }

        }

    }

}
