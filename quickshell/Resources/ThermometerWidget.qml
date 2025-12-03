import ".."
import QtQuick

Item {
    id: thermometer

    property real temperature: 0
    property real maxTemp: 100
    property color thermoColor: Theme.bbyBlue
    property color bgColor: Theme.backgroundAltSolid

    width: 40
    height: 100

    // Thermometer body (tube)
    Rectangle {
        id: tube

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        width: 12
        height: parent.height - 24
        color: bgColor
        radius: 6
        border.width: 2
        border.color: thermoColor

        // Mercury/liquid fill
        Rectangle {
            id: mercury

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 4
            height: Math.max(0, Math.min(parent.height, (thermometer.temperature / thermometer.maxTemp) * parent.height))
            color: thermoColor
            radius: 4

            Behavior on height {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    // Bulb at bottom
    Rectangle {
        id: bulb

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: 22
        height: 22
        radius: 10
        color: thermoColor
        border.width: 2
        border.color: thermoColor
    }

    // Tick marks
    Column {
        anchors.right: tube.left
        anchors.rightMargin: 4
        anchors.topMargin: 4
        anchors.top: tube.top
        anchors.bottom: tube.bottom
        spacing: (tube.height - 20) / 4

        Repeater {
            model: 5

            Rectangle {
                width: 4
                height: 1
                color: Theme.textMuted
            }

        }

    }

}
