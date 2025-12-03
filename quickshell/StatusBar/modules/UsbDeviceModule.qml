import QtQuick
import Quickshell.Io

Item {
    id: usbModule

    property string screenName: ""

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

    Row {
        id: usbRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: controllerIcon
            font.family: Theme.fontMono
            font.weight: Font.Bold
            color: Theme.primary
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: controllerConnected && !controllerWired
            text: controllerBattery + "%"
            font.family: Theme.fontMono
            color: Theme.textSecondary
            width: 30
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
