// Widgets/GpuWidget.qml
import ".."
import QtQuick

Rectangle {
    id: gpuWidget

    property bool isVisible: false

    anchors.fill: parent
    color: Theme.backgroundSolid
    radius: 20
    border.width: 3
    border.color: Theme.primary

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
                value: GpuDataProvider.gpuUsage
                gaugeColor: Theme.green
            }

            Text {
                text: Math.round(GpuDataProvider.gpuUsage) + "%"
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
                value: GpuDataProvider.vramUsage
                gaugeColor: Theme.green
            }

            Text {
                text: GpuDataProvider.vramUsed.toFixed(1) + "GB"
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
                temperature: GpuDataProvider.gpuTemp
                maxTemp: 90
                thermoColor: Theme.green
            }

            Text {
                text: Math.round(GpuDataProvider.gpuTemp) + "°C"
                font.family: Theme.fontMono
                font.pixelSize: 16
                font.weight: Font.Bold
                color: Theme.textPrimary
                anchors.horizontalCenter: parent.horizontalCenter
            }

        }

    }

    // GPU vendor badge
    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 12
        text: {
            if (GpuDataProvider.gpuVendor === "nvidia")
                return "NVIDIA";

            if (GpuDataProvider.gpuVendor === "amd")
                return "AMD Radeon";

            if (GpuDataProvider.gpuVendor === "intel")
                return "Intel";

            return "Unknown GPU";
        }
        font.family: Theme.fontMono
        font.weight: Font.Bold
        font.pixelSize: 14
        color: Theme.textPrimary
    }

}
