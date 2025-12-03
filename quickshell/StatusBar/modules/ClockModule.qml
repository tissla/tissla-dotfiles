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

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
            WidgetManager.setMousePosition(globalPos.x);
            CalendarState.toggle();
        }
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

}
