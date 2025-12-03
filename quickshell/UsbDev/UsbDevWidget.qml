import ".."
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: usbDevWidget

    property bool isVisible: false
    // Device status
    property bool controllerConnected: false
    property bool controllerWired: false // USB vs Bluetooth
    property int controllerBattery: 0 // 0-100%
    property string controllerIcon: "󰖻" // Disconnected icon

    anchors.fill: parent
    color: Theme.background
    radius: 20
    border.width: 3
    border.color: Theme.primary

    // Timer - uppdatera var 3:e sekund (samma som waybar)
    Timer {
        id: updateTimer

        interval: 3000
        running: usbDevWidget.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkControllerProcess.running = true;
        }
    }

    // Check controller status
    Process {
        id: checkControllerProcess

        running: false
        command: ["sh", "-c", "if lsusb | grep -qi 'Xbox'; then " + "  echo 'WIRED'; " + "else " + "  bt_info=$(bluetoothctl info); " + "  if echo \"$bt_info\" | grep -q Xbox; then " + "    battery=$(echo \"$bt_info\" | grep 'Battery Percentage:' | awk -F'[()]' '{ print $2 }'); " + "    echo \"BLUETOOTH:$battery\"; " + "  else " + "    echo 'DISCONNECTED'; " + "  fi; " + "fi"]

        stdout: StdioCollector {
            onStreamFinished: {
                let status = text.trim();
                if (status === "WIRED") {
                    controllerConnected = true;
                    controllerWired = true;
                    controllerBattery = 100;
                    controllerIcon = "󰖺"; // Connected icon
                    console.log("Controller: Wired");
                } else if (status.startsWith("BLUETOOTH:")) {
                    let battery = status.split(":")[1];
                    controllerConnected = true;
                    controllerWired = false;
                    controllerBattery = parseInt(battery) || 0;
                    controllerIcon = "󰖺";
                    console.log("Controller: Bluetooth", controllerBattery + "%");
                } else {
                    controllerConnected = false;
                    controllerWired = false;
                    controllerBattery = 0;
                    controllerIcon = "󰖻"; // Disconnected icon
                    console.log("Controller: Disconnected");
                }
            }
        }

    }

    // UI Layout
    Column {
        anchors.centerIn: parent
        spacing: 12

        // Controller Icon
        Text {
            text: usbDevWidget.controllerIcon
            font.pixelSize: 64
            color: usbDevWidget.controllerConnected ? Theme.primary : Theme.textMuted
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
                if (!usbDevWidget.controllerConnected)
                    return "Disconnected";
                else if (usbDevWidget.controllerWired)
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
            visible: usbDevWidget.controllerConnected && !usbDevWidget.controllerWired
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
                    width: Math.max(0, (parent.width - 4) * (usbDevWidget.controllerBattery / 100))
                    height: parent.height - 4
                    radius: 4
                    color: {
                        if (usbDevWidget.controllerBattery > 50)
                            return "#4ade80";

                        // Green
                        if (usbDevWidget.controllerBattery > 20)
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
                text: usbDevWidget.controllerBattery + "%"
                font.family: Theme.fontMono
                font.pixelSize: 14
                color: Theme.textPrimary
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
