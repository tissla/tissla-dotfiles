import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: performanceData

    property bool run: false
    property real cpuUsage: 0
    property real cpuTemp: 0
    property real ramUsage: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real liquidTemp: 0
    property int pumpSpeed: 0
    property var prevCpuTimes: ({
        "idle": 0,
        "iowait": 0,
        "user": 0,
        "nice": 0,
        "system": 0,
        "irq": 0,
        "softirq": 0,
        "steal": 0
    })
    property Process cpuProcess
    // RAM via /proc/meminfo
    property Process ramProcess
    // sensors
    property Process sensorsProcess

    function startPolling() {
        run = true;
    }

    function stopPolling() {
        run = false;
    }

    function parseSensors(output) {
        let tctlMatch = output.match(/Tctl:\s+\+([\d.]+)°C/);
        if (tctlMatch)
            cpuTemp = parseFloat(tctlMatch[1]);

        let liquidMatch = output.match(/Coolant temp:\s+\+([\d.]+)°C/);
        if (liquidMatch)
            liquidTemp = parseFloat(liquidMatch[1]);

        let pumpMatch = output.match(/Pump speed:\s+(\d+)\s+RPM/);
        if (pumpMatch)
            pumpSpeed = parseInt(pumpMatch[1]);

        console.log("pump speed:", pumpSpeed);
        console.log("cpu temp:", cpuTemp);
        console.log("liquid temp:", liquidTemp);
    }

    cpuProcess: Process {
        running: true
        command: ["vmstat", "2"]

        stdout: SplitParser {
            property int lineCount: 0

            onRead: (line) => {
                lineCount++;
                // skip headers
                if (lineCount <= 2)
                    return ;

                let parts = line.trim().split(/\s+/);
                if (parts.length >= 15) {
                    let idle = parseFloat(parts[14]);
                    performanceData.cpuUsage = 100 - idle;
                }
            }
        }

    }

    ramProcess: Process {
        running: performanceData.run
        command: ["sh", "-c", "while true; do grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; echo '---'; sleep 2; done"]

        stdout: SplitParser {
            property real memTotal: 0
            property real memAvailable: 0

            onRead: (line) => {
                if (line.startsWith("MemTotal")) {
                    memTotal = parseFloat(line.split(/\s+/)[1]);
                    performanceData.ramTotal = memTotal / 1024 / 1024;
                } else if (line.startsWith("MemAvailable")) {
                    memAvailable = parseFloat(line.split(/\s+/)[1]);
                    let used = memTotal - memAvailable;
                    performanceData.ramUsed = used / 1024 / 1024;
                    performanceData.ramUsage = (used / memTotal) * 100;
                }
            }
        }

    }

    sensorsProcess: Process {
        running: performanceData.run
        command: ["sh", "-c", "while true; do sensors -A; echo '===END==='; sleep 3; done"]

        stdout: SplitParser {
            property string buffer: ""

            onRead: (line) => {
                if (line.endsWith("===END===")) {
                    buffer += line.slice(0, line.length - "===END===".length);
                    performanceData.parseSensors(buffer);
                    buffer = "";
                } else {
                    buffer += line + "\n";
                }
            }
        }

    }

}
