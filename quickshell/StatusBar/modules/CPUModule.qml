import "../.."
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: cpuModule

    property string screenName: ""
    property real cpuUsage: 0

    width: cpuRow.width + 16
    height: 30

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
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]

        stdout: StdioCollector {
            onStreamFinished: {
                let usage = parseFloat(text);
                if (!isNaN(usage))
                    cpuModule.cpuUsage = usage;

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
            // centering offset..
            anchors.verticalCenterOffset: -2
        }

        Text {
            text: Math.round(cpuModule.cpuUsage) + "%"
            font.family: Theme.fontCalendar
            font.pixelSize: 14
            font.weight: Font.Bold
            color: Theme.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            CpuRamState.toggle();
        }
    }

}
