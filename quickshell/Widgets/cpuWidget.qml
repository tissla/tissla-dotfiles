import ".."
import QtQuick

BaseWidget {
    id: cpuRamWidget

    widgetId: "cpu"
    widgetWidth: 500
    widgetHeight: 220

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
                        color: Theme.accent
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Gauge {
                        id: cpuGauge

                        width: 80
                        height: 80
                        value: PerformanceDataProvider.cpuUsage
                        gaugeColor: Theme.accent
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.cpuUsage) + "%"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
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
                        color: Theme.accent
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Gauge {
                        id: ramGauge

                        width: 80
                        height: 80
                        value: PerformanceDataProvider.ramUsage
                        gaugeColor: Theme.warning
                    }

                    Text {
                        text: PerformanceDataProvider.ramUsed.toFixed(1) + "GB"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
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
                        color: Theme.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Gauge {
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
                        color: Theme.text
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
                        color: Theme.accent
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Thermometer {
                        id: cpuThermo

                        width: 40
                        height: 80
                        temperature: PerformanceDataProvider.cpuTemp
                        maxTemp: 100
                        thermoColor: Theme.warning
                    }

                    Text {
                        text: Math.round(PerformanceDataProvider.cpuTemp) + "°C"
                        font.family: Theme.fontMain
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Theme.text
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
                        color: Theme.accent
                        font.weight: Font.Bold
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Thermometer {
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
                        color: Theme.text
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                }

            }

        }

    }

}
