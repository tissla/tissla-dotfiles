import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: gpuModule

    property string screenName: ""
    property real gpuUsage: 0

    width: gpuRow.width + 16
    height: 30

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getGpuProcess.running = true;
        }
    }

    Process {
        id: getGpuProcess

        running: false
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                let usage = parseFloat(text);
                if (!isNaN(usage))
                    gpuModule.gpuUsage = usage;

            }
        }

    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
            WidgetManager.setMousePosition(globalPos.x);
            GpuState.toggle();
        }
    }

    Row {
        id: gpuRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: "󰢮"
            font.pixelSize: 20
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(gpuModule.gpuUsage) + "%"
            font.family: Theme.fontMono
            font.pixelSize: 14
            font.weight: Font.Bold
            width: 30
            color: Theme.textSecondary
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
