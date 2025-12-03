import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: cpuModule

    property string screenName: ""
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

    width: cpuRow.width + 16
    height: 30

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
            WidgetManager.setMousePosition(globalPos.x);
            CpuRamState.toggle();
        }
    }

    Timer {
        interval: 2000
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

    Row {
        id: cpuRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: ""
            font.pixelSize: 20
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(cpuModule.cpuUsage) + "%"
            font.family: Theme.fontMono
            font.pixelSize: 14
            font.weight: Font.Bold
            width: 30
            color: Theme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
