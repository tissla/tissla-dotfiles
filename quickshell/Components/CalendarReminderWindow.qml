import QtQuick
import QtQuick.Controls
import Quickshell
import ".."

PanelWindow {
    id: root

    property string day: ""

    function open(selectedDay) {
        day = selectedDay;
        visible = true;
        reminders.editReminder(null);
    }

    visible: false
    focusable: visible
    exclusiveZone: 0
    color: "transparent"
    implicitWidth: 440
    implicitHeight: Math.min(560, screen ? screen.height - 80 : 560,
        Math.max(280, reminders.implicitHeight + 90))
    anchors { top: true; left: true }
    margins {
        top: screen ? Math.max(0, (screen.height - implicitHeight) / 2) : 0
        left: screen ? Math.max(0, (screen.width - implicitWidth) / 2) : 0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.baseSolid
        border.width: Theme.borderWidth
        border.color: Theme.accent
        radius: Theme.radius
        Keys.onEscapePressed: root.visible = false

        Text {
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.day
            color: Theme.text
            font.family: Theme.fontMain
            font.pixelSize: Theme.fontSizeMd
            font.bold: true
        }

        Button {
            id: closeButton
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 12
            width: 28
            height: 28
            Accessible.name: "Close reminders"
            onClicked: root.visible = false
            contentItem: Text {
                text: "×"
                color: Theme.text
                font.pixelSize: 20
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle {
                color: closeButton.hovered || closeButton.activeFocus ? Theme.surface2 : "transparent"
                radius: Theme.radiusAlt
            }
        }

        ScrollView {
            id: scroll
            anchors.fill: parent
            anchors.margins: 24
            anchors.topMargin: 58
            clip: true
            contentWidth: availableWidth
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            CalendarReminders {
                id: reminders
                width: scroll.availableWidth
                day: root.day
                onSaved: root.visible = false
                onCancelled: root.visible = false
            }
        }
    }
}
