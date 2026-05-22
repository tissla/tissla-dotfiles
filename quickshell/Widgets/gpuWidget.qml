import ".."
import QtQuick

BaseWidget {
    id: gpuWidget

    widgetId: "gpu"
    widgetHeight: 220
    widgetWidth: 340

    widgetComponent: Rectangle {
        color: Theme.base
        radius: Theme.radius
        border.width: 3
        border.color: Theme.accent

        Rectangle {
            width: parent.width - 30
            height: parent.height - 30
            color: "transparent"
            radius: Theme.radius
            anchors.centerIn: parent

            // UI Layout
            Row {
                anchors.centerIn: parent
                anchors.margins: 20
                spacing: 30

                // GPU Usage Gauge
                Column {
                    spacing: 10

                    Text {
                        text: "GPU%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Gauge {
                        id: gpuGauge

                        width: 80
                        height: 80
                        value: GpuDataProvider.gpuUsage
                        gaugeColor: Theme.success
                    }

                    Text {
                        text: Math.round(GpuDataProvider.gpuUsage) + "%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                // VRAM Gauge
                Column {
                    spacing: 10

                    Text {
                        text: "VRAM"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        color: Theme.accent
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Gauge {
                        id: vramGauge

                        width: 80
                        height: 80
                        value: GpuDataProvider.vramUsage
                        gaugeColor: Theme.success
                    }

                    Text {
                        text: GpuDataProvider.vramUsed.toFixed(1) + "GB"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                // GPU Temp thermometer
                Column {
                    spacing: 10

                    Text {
                        text: "GPU°"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        color: Theme.accent
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Thermometer {
                        id: gpuThermo

                        width: 40
                        height: 80
                        temperature: GpuDataProvider.gpuTemp
                        maxTemp: 90
                        thermoColor: Theme.success
                    }

                    Text {
                        text: Math.round(GpuDataProvider.gpuTemp) + "°C"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

            }

        }

    }

}
