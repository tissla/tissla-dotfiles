import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: networkModule

    property string screenName: ""
    property string nwInterface: ""
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property bool connected: false

    function formatSpeed(kbps) {
        if (kbps < 1)
            return "0 KB/s";
        else if (kbps < 1024)
            return Math.round(kbps) + " KB/s";
        else
            return (kbps / 1024).toFixed(1) + " MB/s";
    }

    width: networkRow.width + 16
    height: 30
    // Detect active interface on startup
    Component.onCompleted: {
        detectInterfaceProcess.running = true;
    }

    // Detect active network interface
    Process {
        // Get default route interface (most reliable)

        id: detectInterfaceProcess

        running: false
        command: ["sh", "-c", "ip route show default | awk '/default/ {print $5}' | head -1"]

        stdout: StdioCollector {
            onStreamFinished: {
                let iface = text.trim();
                if (iface.length > 0) {
                    networkModule.nwInterface = iface;
                    networkModule.connected = true;
                    console.log("[NetworkModule] Detected network interface:", iface);
                    // Start monitoring now that we have interface
                    monitorTimer.start();
                } else {
                    console.log(" No active network interface found");
                }
            }
        }

    }

    Timer {
        id: monitorTimer

        interval: 1000
        running: false // Start after interface detection
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (networkModule.nwInterface)
                getNetworkProcess.running = true;

        }
    }

    Process {
        id: getNetworkProcess

        property real lastRx: 0
        property real lastTx: 0
        property real lastTime: Date.now()

        running: false
        command: ["sh", "-c", "cat /sys/class/net/" + networkModule.nwInterface + "/statistics/rx_bytes " + "/sys/class/net/" + networkModule.nwInterface + "/statistics/tx_bytes 2>/dev/null || echo '0 0'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    let rx = parseInt(parts[0]);
                    let tx = parseInt(parts[1]);
                    let now = Date.now();
                    if (getNetworkProcess.lastRx > 0 && rx > 0 && tx > 0) {
                        let timeDelta = (now - getNetworkProcess.lastTime) / 1000;
                        networkModule.downloadSpeed = (rx - getNetworkProcess.lastRx) / timeDelta / 1024;
                        networkModule.uploadSpeed = (tx - getNetworkProcess.lastTx) / timeDelta / 1024;
                        networkModule.connected = true;
                    } else if (rx === 0 && tx === 0) {
                        // Interface might have changed, re-detect
                        networkModule.connected = false;
                        detectInterfaceProcess.running = true;
                    }
                    getNetworkProcess.lastRx = rx;
                    getNetworkProcess.lastTx = tx;
                    getNetworkProcess.lastTime = now;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    // Interface probably changed, re-detect
                    console.log("Network interface error, re-detecting...");
                    networkModule.connected = false;
                    detectInterfaceProcess.running = true;
                }
            }
        }

    }

    Row {
        id: networkRow

        anchors.centerIn: parent
        spacing: 8

        // TODO: add functionality to show wifi/ethernet icon dynamically 󰖩󰖩󰖩
        Text {
            text: networkModule.connected ? "󰖩" : "󰖪"
            font.pixelSize: 20
            color: networkModule.connected ? Theme.primary : Theme.accent
            anchors.verticalCenter: parent.verticalCenter
            font.family: Theme.fontMono
        }

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            visible: networkModule.connected

            Text {
                text: networkModule.formatSpeed(networkModule.downloadSpeed)
                font.family: Theme.fontMono
                font.pixelSize: 15
                font.weight: Font.Bold
                color: Theme.textSecondary
                width: 80
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "↓"
                font.pixelSize: 20
                color: Theme.primary
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: networkModule.formatSpeed(networkModule.uploadSpeed)
                font.family: Theme.fontMono
                font.pixelSize: 15
                width: 80
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignRight
                color: Theme.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "↑"
                font.pixelSize: 20
                color: Theme.primary
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        Text {
            visible: !networkModule.connected
            text: "down"
            font.family: Theme.fontMono
            font.pixelSize: 13
            font.weight: Font.Bold
            color: Theme.accent
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
    }

}
