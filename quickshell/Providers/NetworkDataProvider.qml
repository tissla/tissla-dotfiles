pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: networkData
    property bool pollingEnabled: true
    property string nwInterface: ""
    property real downloadSpeed: 0
    property real uploadSpeed: 0
    property bool connected: false
    property var history: []
    readonly property int historySeconds: 180
    property real lastRx: -1
    property real lastTx: -1
    property double lastTime: 0

    function formatSpeed(kbps) {
        if (!Number.isFinite(kbps) || kbps < 1) return "0 KB/s";
        if (kbps < 1024) return Math.round(kbps) + " KB/s";
        if (kbps < 1048576) return (kbps / 1024).toFixed(1) + " MB/s";
        return (kbps / 1048576).toFixed(1) + " GB/s";
    }
    function disconnect() {
        connected = false;
        nwInterface = "";
        downloadSpeed = 0;
        uploadSpeed = 0;
        lastRx = -1;
        lastTx = -1;
        lastTime = 0;
        history = [];
    }
    function acceptCounters(iface, rx, tx, at) {
        if (!iface || !Number.isFinite(rx) || !Number.isFinite(tx) || rx < 0 || tx < 0 || !Number.isFinite(at)) {
            disconnect();
            return;
        }
        if (iface !== nwInterface) {
            disconnect();
            nwInterface = iface;
        }
        connected = true;
        if (lastRx >= 0 && at > lastTime && rx >= lastRx && tx >= lastTx) {
            const seconds = (at - lastTime) / 1000;
            downloadSpeed = (rx - lastRx) / seconds / 1024;
            uploadSpeed = (tx - lastTx) / seconds / 1024;
            history = history.filter(p => p.at > at - historySeconds * 1000).concat([
                {at: at, download: downloadSpeed, upload: uploadSpeed}
            ]).slice(-90);
        } else {
            downloadSpeed = 0;
            uploadSpeed = 0;
            history = [];
        }
        lastRx = rx;
        lastTx = tx;
        lastTime = at;
    }
    property Timer pollTimer: Timer {
        interval: 2000
        running: networkData.pollingEnabled
        triggeredOnStart: true
        repeat: true
        onTriggered: if (!networkData.netProcess.running) networkData.netProcess.running = true
    }
    // Read the route and counters together. Each invocation exits, so changing interfaces
    // cannot leave the previous interface's reader alive or mix its baseline with a new one.
    property Process netProcess: Process {
        command: ["sh", "-c", `
            iface=$( { ip -o -4 route show default; ip -o -6 route show default; } 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
            [ -n "$iface" ] || exit 1
            printf '%s\\n' "$iface"
            cat "/sys/class/net/$iface/statistics/rx_bytes" "/sys/class/net/$iface/statistics/tx_bytes"
        `]
        stdout: StdioCollector { id: counters }
        stderr: StdioCollector {}
        onExited: (exitCode, exitStatus) => {
            const values = counters.text.trim().split("\n");
            if (exitCode || exitStatus || values.length !== 3) networkData.disconnect();
            else networkData.acceptCounters(values[0], Number(values[1]), Number(values[2]), Date.now());
        }
    }
}
