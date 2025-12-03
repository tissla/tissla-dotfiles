import ".."
import QtQuick
import Quickshell.Io

Rectangle {
    id: gpuWidget

    property bool isVisible: false
    // Data properties
    property real gpuUsage: 0
    property real gpuTemp: 0
    property real vramUsed: 0
    property real vramTotal: 0
    property real vramUsage: 0

    anchors.fill: parent
    color: Theme.backgroundSolid
    radius: 20
    border.width: 3
    border.color: Theme.primary

    // Timer
    Timer {
        id: updateTimer

        interval: 1000
        running: gpuWidget.isVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getAllGpuDataProcess.running = true;
        }
    }

    // All GPU data in one process
    Process {
        id: getAllGpuDataProcess

        running: false
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,memory.used,memory.total --format=csv,noheader,nounits"]

        stdout: StdioCollector {
            onStreamFinished: {
                let values = text.trim().split(",").map((v) => {
                    return parseFloat(v.trim());
                });
                if (values.length >= 4) {
                    gpuUsage = values[0];
                    gpuTemp = values[1];
                    vramUsed = values[2] / 1024; // MB to GB
                    vramTotal = values[3] / 1024;
                    vramUsage = (values[2] / values[3]) * 100;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.log("GPU error:", text);

            }
        }

    }

    // UI Layout
    Row {
        anchors.centerIn: parent
        anchors.margins: 20
        spacing: 16

        // GPU Usage Gauge
        Column {
            spacing: 4

            Text {
                text: "GPU%"
                font.family: Theme.fontMain
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            GaugeWidget {
                id: gpuGauge

                width: 80
                height: 80
                value: gpuWidget.gpuUsage
                gaugeColor: Theme.green
            }

            Text {
                text: Math.round(gpuWidget.gpuUsage) + "%"
                font.family: Theme.fontMono
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

        // VRAM Gauge
        Column {
            spacing: 4

            Text {
                text: "VRAM"
                font.family: Theme.fontMain
                font.pixelSize: 16
                color: Theme.primary
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            GaugeWidget {
                id: vramGauge

                width: 80
                height: 80
                value: gpuWidget.vramUsage
                gaugeColor: Theme.green
            }

            Text {
                text: gpuWidget.vramUsed.toFixed(1) + "GB"
                font.family: Theme.fontMono
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

        // GPU Temp thermometer
        Column {
            spacing: 4

            Text {
                text: "GPU°"
                font.family: Theme.fontMain
                font.pixelSize: 16
                color: Theme.primary
                font.weight: Font.Bold
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ThermometerWidget {
                id: gpuThermo

                width: 40
                height: 80
                temperature: gpuWidget.gpuTemp
                maxTemp: 90
                thermoColor: Theme.green
            }

            Text {
                text: Math.round(gpuWidget.gpuTemp) + "°C"
                font.family: Theme.fontMono
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

    }

}
