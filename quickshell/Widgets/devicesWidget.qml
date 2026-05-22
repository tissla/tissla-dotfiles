import ".."
// Devices/DevicesWidget.qml
import QtQuick

BaseWidget {
    id: usbDevWidget

    widgetId: "devices"
    widgetWidth: 200
    widgetHeight: 180

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: 3
        border.color: Theme.accent

        Column {
            anchors.centerIn: parent
            spacing: 12

            // Controller Icon
            Text {
                text: DevicesDataProvider.controllerIcon
                font.pixelSize: 64
                color: DevicesDataProvider.controllerConnected ? Theme.accent : Theme.muted
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
                    if (!DevicesDataProvider.controllerConnected)
                        return "Disconnected";
                    else if (DevicesDataProvider.controllerWired)
                        return "Wired";
                    else
                        return "Bluetooth";
                }
                font.family: Theme.fontMain
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.text
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Battery info (only for Bluetooth)
            Row {
                visible: DevicesDataProvider.controllerConnected && !DevicesDataProvider.controllerWired
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
                    color: Theme.mantle
                    radius: 6
                    border.width: 2
                    border.color: Theme.accent
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        // Red

                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 2
                        width: Math.max(0, (parent.width - 4) * (DevicesDataProvider.controllerBattery / 100))
                        height: parent.height - 4
                        radius: 4
                        color: {
                            if (DevicesDataProvider.controllerBattery > 50)
                                return "#4ade80";

                            // Green
                            if (DevicesDataProvider.controllerBattery > 20)
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
                    text: DevicesDataProvider.controllerBattery + "%"
                    font.family: Theme.fontMain
                    font.pixelSize: 14
                    color: Theme.text
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
            font.family: Theme.fontMain
            font.pixelSize: 12
            color: Theme.muted
        }

    }

}
