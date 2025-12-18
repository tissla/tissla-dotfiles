import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    // Get default route interface

    id: networkData

    // interface name
    property string nwInterface: ""
    // speed
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    // history
    property var downloadHistory: []
    property var uploadHistory: []
    // 3600 / 5
    property int maxHistoryLength: 720
    property int historyIndex: 0
    // status
    property bool connected: false
    // processes
    property Process detectInterfaceProcess
    property Process getNetworkProcess
    // timers
    property Timer downTimer
    property Timer monitorTimer

    function formatSpeed(kbps) {
        if (kbps < 1)
            return "0 KB/s";
        else if (kbps < 1024)
            return Math.round(kbps) + " KB/s";
        else
            return (kbps / 1024).toFixed(1) + " MB/s";
    }

    Component.onCompleted: {
        detectInterfaceProcess.running = true;
    }

    monitorTimer: Timer {
        // check every 5 second
        interval: 5000
        running: false // Start after interface detection
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (networkData.nwInterface)
                getNetworkProcess.running = true;

        }
    }

    getNetworkProcess: Process {
        property real lastRx: 0
        property real lastTx: 0
        property real lastTime: Date.now()

        running: false
        command: ["sh", "-c", "cat /sys/class/net/" + networkData.nwInterface + "/statistics/rx_bytes " + "/sys/class/net/" + networkData.nwInterface + "/statistics/tx_bytes 2>/dev/null || echo '0 0'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split(/\s+/);
                if (parts.length >= 2) {
                    let rx = parseInt(parts[0]);
                    let tx = parseInt(parts[1]);
                    let now = Date.now();
                    if (getNetworkProcess.lastRx > 0 && rx > 0 && tx > 0) {
                        let timeDelta = (now - getNetworkProcess.lastTime) / 1000;
                        networkData.downloadSpeed = (rx - getNetworkProcess.lastRx) / timeDelta / 1024;
                        networkData.uploadSpeed = (tx - getNetworkProcess.lastTx) / timeDelta / 1024;
                        networkData.connected = true;
                        // Add to history
                        if (networkData.downloadHistory.length >= networkData.maxHistoryLength) {
                            networkData.downloadHistory.shift();
                            networkData.uploadHistory.shift();
                        }
                        networkData.downloadHistory.push(networkData.downloadSpeed);
                        networkData.uploadHistory.push(networkData.uploadSpeed);
                    } else if (rx === 0 && tx === 0) {
                        // Interface might have changed, re-detect
                        networkData.connected = false;
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
                    networkData.connected = false;
                    detectInterfaceProcess.running = true;
                }
            }
        }

    }

    downTimer: Timer {
        interval: 2000
        running: !parent.connected // only running when down
        repeat: true
        onTriggered: detectInterfaceProcess.running = true
    }

    // Detect active network interface
    detectInterfaceProcess: Process {
        running: false
        command: ["sh", "-c", "ip route show default | awk '/default/ {print $5}' | head -1"]

        stdout: StdioCollector {
            onStreamFinished: {
                let iface = text.trim();
                if (iface.length > 0) {
                    networkData.nwInterface = iface;
                    networkData.connected = true;
                    console.log("[NetworkModule] Detected network interface:", iface);
                    // Start monitoring now that we have interface
                    monitorTimer.start();
                } else {
                    console.log(" No active network interface found");
                }
            }
        }

    }

}
