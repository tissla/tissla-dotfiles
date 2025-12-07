import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: performanceData

    property Process getAllDataProcess
    property Timer updateTimer
    property real cpuUsage: 0
    property real cpuTemp: 0
    property real ramUsage: 0
    property real ramUsed: 0
    property real ramTotal: 0
    property real liquidTemp: 0
    property int pumpSpeed: 0
    property var prevCpuTimes: ({
        "user": 0,
        "nice": 0,
        "system": 0,
        "idle": 0,
        "iowait": 0,
        "irq": 0,
        "softirq": 0,
        "steal": 0
    })

    function parseCpuUsage(cpuLine) {
        if (cpuLine.startsWith("cpu ")) {
            let values = cpuLine.split(/\s+/).slice(1).map((x) => {
                return parseInt(x);
            });
            if (values.length >= 8) {
                let currTimes = {
                    "user": values[0],
                    "nice": values[1],
                    "system": values[2],
                    "idle": values[3],
                    "iowait": values[4],
                    "irq": values[5],
                    "softirq": values[6],
                    "steal": values[7]
                };
                let prevIdle = prevCpuTimes.idle + prevCpuTimes.iowait;
                let currIdle = currTimes.idle + currTimes.iowait;
                let prevNonIdle = prevCpuTimes.user + prevCpuTimes.nice + prevCpuTimes.system + prevCpuTimes.irq + prevCpuTimes.softirq + prevCpuTimes.steal;
                let currNonIdle = currTimes.user + currTimes.nice + currTimes.system + currTimes.irq + currTimes.softirq + currTimes.steal;
                let prevTotal = prevIdle + prevNonIdle;
                let currTotal = currIdle + currNonIdle;
                let totalDelta = currTotal - prevTotal;
                let idleDelta = currIdle - prevIdle;
                if (totalDelta > 0)
                    cpuUsage = ((totalDelta - idleDelta) / totalDelta) * 100;

                prevCpuTimes = currTimes;
            }
        }
    }

    function parseRamUsage(ramLine) {
        let parts = ramLine.split(" ");
        if (parts.length >= 2) {
            let used = parseInt(parts[0]);
            let total = parseInt(parts[1]);
            ramUsed = used / 1024; // MB to GB
            ramTotal = total / 1024;
            ramUsage = (used / total) * 100;
        }
    }

    function parseSensors(sensorsOutput) {
        // CPU Temperature (Tctl for AMD Ryzen)
        let tctlMatch = sensorsOutput.match(/Tctl:\s+\+([\d.]+)°C/);
        if (tctlMatch)
            cpuTemp = parseFloat(tctlMatch[1]);

        // Liquid Temperature
        let liquidMatch = sensorsOutput.match(/Coolant temp:\s+\+([\d.]+)°C/);
        if (liquidMatch)
            liquidTemp = parseFloat(liquidMatch[1]);

        // Pump Speed
        let pumpMatch = sensorsOutput.match(/Pump speed:\s+(\d+)\s+RPM/);
        if (pumpMatch)
            pumpSpeed = parseInt(pumpMatch[1]);

    }

    // Single timer
    updateTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getAllDataProcess.running = true;
        }
    }

    // All data in one process
    getAllDataProcess: Process {
        running: false
        command: ["sh", "-c", "cat /proc/stat | head -1; " + "echo '---'; " + "free -m | awk 'NR==2{printf \"%s %s\", $3,$2}'; " + "echo '---'; " + "/usr/bin/sensors -A 2>/dev/null || echo 'sensors not found'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.split("---");
                if (parts.length >= 3) {
                    parseCpuUsage(parts[0].trim());
                    parseRamUsage(parts[1].trim());
                    parseSensors(parts[2].trim());
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.log("Process error:", text);

            }
        }

    }

}
