import ".."
import QtQuick

BaseWidget {
    id: gpuWidget

    widgetId: "gpu"
    widgetHeight: 220
    widgetWidth: 340

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: 3
        border.color: Theme.primary

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
                        color: Theme.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    GaugeWidget {
                        id: gpuGauge

                        width: 80
                        height: 80
                        value: GpuDataProvider.gpuUsage
                        gaugeColor: Theme.active
                    }

                    Text {
                        text: Math.round(GpuDataProvider.gpuUsage) + "%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
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
                        color: Theme.primary
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    GaugeWidget {
                        id: vramGauge

                        width: 80
                        height: 80
                        value: GpuDataProvider.vramUsage
                        gaugeColor: Theme.active
                    }

                    Text {
                        text: GpuDataProvider.vramUsed.toFixed(1) + "GB"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
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
                        color: Theme.primary
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ThermometerWidget {
                        id: gpuThermo

                        width: 40
                        height: 80
                        temperature: GpuDataProvider.gpuTemp
                        maxTemp: 90
                        thermoColor: Theme.active
                    }

                    Text {
                        text: Math.round(GpuDataProvider.gpuTemp) + "°C"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

            }

        }

    }

}
