import "../.."
import QtQuick
import Quickshell

Item {
    id: clockModule

    property bool showDate: false

    width: clockText.width + 40
    height: 30

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: ""
            font.pixelSize: 20
            font.family: Theme.fontMono
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: clockText

            text: Qt.formatDateTime(clock.date, "hh:mm")
            font.family: Theme.fontMono
            font.pixelSize: 15
            width: 30
            font.weight: Font.Bold
            color: Theme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: CalendarState.toggle()
    }

}
