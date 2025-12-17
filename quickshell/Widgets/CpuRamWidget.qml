import ".."
import QtQuick

BaseWidget {
    id: cpuRamWidget

    widgetId: "cpuram"
    widgetWidth: 500
    widgetHeight: 220

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: 3
        border.color: Theme.primary

        Rectangle {
            width: parent.width - 30
            height: parent.height - 30
            color: Theme.backgroundAltSolid
            radius: Theme.radius
            anchors.centerIn: parent

            Row {
                // center contents
                anchors.centerIn: parent
                anchors.margins: 20
                spacing: 30

                // CPU Gauge
                Column {
                    spacing: 10

                    Text {
                        text: "CPU%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        color: Theme.primary
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    GaugeWidget {
                        id: cpuGauge

                        width: 80
                        height: 80
                        value: PerformanceDataProvider.cpuUsage
                        gaugeColor: Theme.primary
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.cpuUsage) + "%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                // RAM Gauge
                Column {
                    spacing: 10

                    Text {
                        text: "RAM"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        color: Theme.primary
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    GaugeWidget {
                        id: ramGauge

                        width: 80
                        height: 80
                        value: PerformanceDataProvider.ramUsage
                        gaugeColor: Theme.accent
                    }

                    Text {
                        text: PerformanceDataProvider.ramUsed.toFixed(1) + "GB"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                Column {
                    spacing: 10

                    Text {
                        text: "AIO"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    GaugeWidget {
                        id: pumpGauge

                        width: 80
                        height: 80
                        value: (PerformanceDataProvider.pumpSpeed / 2500) * 100
                        gaugeColor: Theme.info
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.pumpSpeed) + "rpm"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                // CPU Temp thermometer
                Column {
                    spacing: 10

                    Text {
                        text: "CPU°"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.primary
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ThermometerWidget {
                        id: cpuThermo

                        width: 40
                        height: 80
                        temperature: PerformanceDataProvider.cpuTemp
                        maxTemp: 100
                        thermoColor: Theme.accent
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.cpuTemp) + "°C"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.foreground
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

                // Liquid Temp thermometer
                Column {
                    spacing: 10

                    Text {
                        text: "LIQ 💧"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        color: Theme.primary
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ThermometerWidget {
                        id: liquidThermo

                        width: 40
                        height: 80
                        temperature: PerformanceDataProvider.liquidTemp
                        maxTemp: 60
                        thermoColor: Theme.info
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.liquidTemp) + "°C"
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
