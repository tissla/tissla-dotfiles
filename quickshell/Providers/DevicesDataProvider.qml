import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: devicesData

    property bool isVisible: false
    property bool controllerConnected: false
    property bool controllerWired: false
    property int controllerBattery: 0
    property string controllerIcon: "󰖻"
    property bool isActive: false
    property Process initialFetchProcess
    property Process btMonitorProcess
    property Timer lsusbTimer
    property Process lsusbProcess

    function activate() {
        isActive = true;
        initialFetchProcess.running = true;
        btMonitorProcess.running = true;
        lsusbTimer.running = true;
    }

    function deactivate() {
        isActive = false;
        btMonitorProcess.running = false;
        lsusbTimer.running = false;
    }

    // Fetch current BT state once on activation
    initialFetchProcess: Process {
        running: false
        command: ["sh", "-c", "bluetoothctl info 2>/dev/null"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (/Xbox/i.test(text) && /Connected: yes/.test(text)) {
                    let match = text.match(/Battery Percentage: 0x[0-9a-f]+ \((\d+)\)/);
                    devicesData.controllerConnected = true;
                    devicesData.controllerWired = false;
                    devicesData.controllerBattery = match ? parseInt(match[1]) : 0;
                    devicesData.controllerIcon = "󰖺";
                }
            }
        }
    }

    // Persistent bluetoothctl monitor — reacts to connect/disconnect/battery events
    btMonitorProcess: Process {
        running: false
        command: ["bluetoothctl", "monitor"]

        stdout: SplitParser {
            onRead: (line) => {
                if (!/Xbox/i.test(line))
                    return;

                if (/\[CHG\].*Connected: yes/.test(line)) {
                    devicesData.controllerConnected = true;
                    devicesData.controllerWired = false;
                    devicesData.controllerIcon = "󰖺";
                } else if (/\[CHG\].*Connected: no/.test(line) || /\[DEL\]/.test(line)) {
                    if (!devicesData.controllerWired) {
                        devicesData.controllerConnected = false;
                        devicesData.controllerBattery = 0;
                        devicesData.controllerIcon = "󰖻";
                    }
                } else if (/Battery Percentage/.test(line)) {
                    let match = line.match(/\((\d+)\)/);
                    if (match)
                        devicesData.controllerBattery = parseInt(match[1]);
                }
            }
        }
    }

    // lsusb polling for wired USB — no event system available for USB
    lsusbTimer: Timer {
        interval: 30000
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: lsusbProcess.running = true;
    }

    lsusbProcess: Process {
        running: false
        command: ["sh", "-c", "lsusb | grep -qi Xbox && echo WIRED || echo NOTWIRED"]

        stdout: StdioCollector {
            onStreamFinished: {
                let wired = text.trim() === "WIRED";
                devicesData.controllerWired = wired;
                if (wired) {
                    devicesData.controllerConnected = true;
                    devicesData.controllerBattery = 100;
                    devicesData.controllerIcon = "󰖺";
                }
            }
        }
    }

}
