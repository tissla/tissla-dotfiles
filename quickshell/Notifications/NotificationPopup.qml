pragma ComponentBehavior: Bound

import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    property var notifications: NotificationService.notifications

    screen: Quickshell.screens[0]
    color: "transparent"
    exclusiveZone: 0
    implicitWidth: 340
    implicitHeight: Math.min(notificationList.contentHeight + Theme.gap * 2, screen ? screen.height - 80 : 700)
    visible: notifications.length > 0

    anchors {
        top: true
        right: true
    }

    ListView {
        id: notificationList
        anchors.fill: parent
        anchors.margins: Theme.gap
        spacing: 12
        clip: true
        model: root.notifications
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}

        delegate: Rectangle {
            id: card
            required property var modelData
            readonly property var notif: modelData

            width: notificationList.width
            implicitHeight: content.implicitHeight + 30
            radius: Theme.radius
            color: Theme.baseSolid
            border.color: Theme.accent
            border.width: Theme.borderWidth

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.margins: 15
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: card.notif.appName
                        textFormat: Text.PlainText
                        color: Theme.subtext1
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    Button {
                        id: dismissButton
                        text: "×"
                        implicitWidth: 28
                        implicitHeight: 28
                        Accessible.name: "Dismiss notification"
                        onClicked: NotificationService.removeNotif(card.notif)
                        contentItem: Text {
                            text: "×"
                            color: Theme.text
                            font.pixelSize: 20
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: dismissButton.hovered ? Theme.surface2 : Theme.surface0
                            radius: Theme.radiusAlt
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: card.notif.summary
                    textFormat: Text.PlainText
                    wrapMode: Text.Wrap
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.weight: Font.Bold
                    font.pixelSize: Theme.fontSizeMd
                }

                RowLayout {
                    Layout.fillWidth: true
                    visible: !!card.notif.image || card.notif.body.length > 0
                    Image {
                        visible: !!card.notif.image
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        source: card.notif.image || ""
                        fillMode: Image.PreserveAspectFit
                    }
                    Text {
                        Layout.fillWidth: true
                        text: card.notif.body
                        textFormat: Text.PlainText
                        wrapMode: Text.Wrap
                        color: Theme.text
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                    }
                }
            }
        }
    }
}
