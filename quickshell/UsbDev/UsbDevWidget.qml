import ".."
// UsbDev/UsbDevWidget.qml
import QtQuick

Rectangle {
    id: usbDevWidget

    property bool isVisible: false

    anchors.fill: parent
    color: Theme.background
    radius: 20
    border.width: 3
    border.color: Theme.primary

    Column {
        anchors.centerIn: parent
        spacing: 12

        // Controller Icon
        Text {
            text: UsbDevState.controllerIcon
            font.pixelSize: 64
            color: UsbDevState.controllerConnected ? Theme.primary : Theme.textMuted
            anchors.horizontalCenter: parent.horizontalCenter

            Behavior on color {
                ColorAnimation {
                    duration: 300
                }

            }

        }

        // Status Text
        Text {
            text: {
                if (!UsbDevState.controllerConnected)
                    return "Disconnected";
                else if (UsbDevState.controllerWired)
                    return "Wired";
                else
                    return "Bluetooth";
            }
            font.family: Theme.fontMono
            font.pixelSize: 16
            font.weight: Font.Bold
            color: Theme.textPrimary
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Battery info (only for Bluetooth)
        Row {
            visible: UsbDevState.controllerConnected && !UsbDevState.controllerWired
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8

            Text {
                text: "🔋"
                font.pixelSize: 20
                anchors.verticalCenter: parent.verticalCenter
            }

            // Battery bar
            Rectangle {
                width: 100
                height: 12
                color: Theme.backgroundAlt
                radius: 6
                border.width: 2
                border.color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    // Red

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 2
                    width: Math.max(0, (parent.width - 4) * (UsbDevState.controllerBattery / 100))
                    height: parent.height - 4
                    radius: 4
                    color: {
                        if (UsbDevState.controllerBattery > 50)
                            return "#4ade80";

                        // Green
                        if (UsbDevState.controllerBattery > 20)
                            return "#fbbf24";

                        // Yellow
                        return "#ef4444";
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                        }

                    }

                }

            }

            Text {
                text: UsbDevState.controllerBattery + "%"
                font.family: Theme.fontMono
                font.pixelSize: 14
                color: Theme.textPrimary
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

    // Device name at bottom
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8
        text: "🎮 Xbox Controller"
        font.family: Theme.fontMono
        font.pixelSize: 12
        color: Theme.textMuted
    }

}
