import "../.."
import QtQuick
import Quickshell.Io

BaseModule {
    id: cpuModule

    property real cpuUsage: 0
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
                let prevIdle = cpuModule.prevCpuTimes.idle + cpuModule.prevCpuTimes.iowait;
                let currIdle = currTimes.idle + currTimes.iowait;
                let prevNonIdle = cpuModule.prevCpuTimes.user + cpuModule.prevCpuTimes.nice + cpuModule.prevCpuTimes.system + cpuModule.prevCpuTimes.irq + cpuModule.prevCpuTimes.softirq + cpuModule.prevCpuTimes.steal;
                let currNonIdle = currTimes.user + currTimes.nice + currTimes.system + currTimes.irq + currTimes.softirq + currTimes.steal;
                let prevTotal = prevIdle + prevNonIdle;
                let currTotal = currIdle + currNonIdle;
                let totalDelta = currTotal - prevTotal;
                let idleDelta = currIdle - prevIdle;
                if (totalDelta > 0)
                    cpuModule.cpuUsage = ((totalDelta - idleDelta) / totalDelta) * 100;

                cpuModule.prevCpuTimes = currTimes;
            }
        }
    }

    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    widgetId: "cpu"
    moduleIcon: ""
    moduleText: Math.round(cpuModule.cpuUsage) + "%"

    Timer {
        // 5 sec updates is enough for a statusbar
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getCpuProcess.running = true;
        }
    }

    Process {
        id: getCpuProcess

        running: false
        command: ["sh", "-c", "cat /proc/stat | head -1"]

        stdout: StdioCollector {
            onStreamFinished: {
                parseCpuUsage(text.trim());
            }
        }

    }

}
