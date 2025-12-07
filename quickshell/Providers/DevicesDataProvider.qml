import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: state

    property bool isVisible: false
    property bool controllerConnected: false
    property bool controllerWired: false
    property int controllerBattery: 0
    property string controllerIcon: "󰖻"
    property Timer updateTimer
    property Process checkControllerProcess

    function toggle() {
        isVisible = !isVisible;
    }

    function show() {
        isVisible = true;
    }

    function hide() {
        isVisible = false;
    }

    updateTimer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkControllerProcess.running = true;
        }
    }

    // TODO: make dynamic
    checkControllerProcess: Process {
        running: false
        command: ["sh", "-c", "if lsusb | grep -qi 'Xbox'; then " + "  echo 'WIRED'; " + "else " + "  bt_info=$(bluetoothctl info); " + "  if echo \"$bt_info\" | grep -q Xbox; then " + "    battery=$(echo \"$bt_info\" | grep 'Battery Percentage:' | awk -F'[()]' '{ print $2 }'); " + "    echo \"BLUETOOTH:$battery\"; " + "  else " + "    echo 'DISCONNECTED'; " + "  fi; " + "fi"]

        stdout: StdioCollector {
            onStreamFinished: {
                let status = text.trim();
                if (status === "WIRED") {
                    state.controllerConnected = true;
                    state.controllerWired = true;
                    state.controllerBattery = 100;
                    state.controllerIcon = "󰖺";
                } else if (status.startsWith("BLUETOOTH:")) {
                    let battery = status.split(":")[1];
                    state.controllerConnected = true;
                    state.controllerWired = false;
                    state.controllerBattery = parseInt(battery) || 0;
                    state.controllerIcon = "󰖺";
                } else {
                    state.controllerConnected = false;
                    state.controllerWired = false;
                    state.controllerBattery = 0;
                    state.controllerIcon = "󰖻";
                }
            }
        }

    }

}
