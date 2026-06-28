import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: networkData

    property string nwInterface: ""
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property bool connected: false
    property Process detectProcess
    property Process netProcess

    function formatSpeed(kbps) {
        if (kbps < 1)
            return "0 KB/s";

        if (kbps < 1024)
            return Math.round(kbps) + " KB/s";

        return (kbps / 1024).toFixed(1) + " MB/s";
    }

    detectProcess: Process {
        running: true
        command: ["sh", "-c", "ip route show default | awk '/default/ {print $5}' | head -1"]

        stdout: StdioCollector {
            onStreamFinished: {
                let iface = text.trim();
                if (iface.length > 0) {
                    networkData.nwInterface = iface;
                    networkData.connected = true;
                    netProcess.running = true;
                }
            }
        }

    }

    netProcess: Process {
        property real lastRx: 0
        property real lastTx: 0
        property real lastTime: Date.now()
        property real pendingRx: -1
        property real pendingTx: 0

        running: false
        command: ["sh", "-c", `while true; do
            cat /sys/class/net/${networkData.nwInterface}/statistics/rx_bytes
            cat /sys/class/net/${networkData.nwInterface}/statistics/tx_bytes
            echo '---'
            sleep 2
        done`]

        stdout: SplitParser {
            onRead: (line) => {
                if (line === "---") {
                    if (netProcess.pendingRx >= 0) {
                        let rx = netProcess.pendingRx;
                        let tx = netProcess.pendingTx;
                        let now = Date.now();
                        if (netProcess.lastRx > 0) {
                            let dt = (now - netProcess.lastTime) / 1000;
                            networkData.downloadSpeed = (rx - netProcess.lastRx) / dt / 1024;
                            networkData.uploadSpeed = (tx - netProcess.lastTx) / dt / 1024;
                        }
                        netProcess.lastRx = rx;
                        netProcess.lastTx = tx;
                        netProcess.lastTime = now;
                        netProcess.pendingRx = -1;
                    }
                } else if (netProcess.pendingRx < 0) {
                    netProcess.pendingRx = parseFloat(line);
                } else {
                    netProcess.pendingTx = parseFloat(line);
                }
            }
        }

    }

}
