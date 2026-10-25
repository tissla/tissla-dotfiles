pragma ComponentBehavior: Bound
import ".."
import QtQuick
import QtQuick.Layouts

BaseWidget {
    id: networkWidget
    widgetId: "network"
    widgetWidth: Math.min(520, screen ? screen.width - 40 : 520)
    widgetHeight: Math.min(420, screen ? screen.height - 100 : 420)

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Network"; font.pixelSize: Theme.fontSizeXl; font.bold: true; Layout.fillWidth: true }
                Rectangle { implicitWidth: 7; implicitHeight: 7; radius: 4; color: NetworkDataProvider.connected ? Theme.success : Theme.warning }
                Label { text: NetworkDataProvider.connected ? NetworkDataProvider.nwInterface : "Disconnected"; color: Theme.subtext1 }
            }
            NetworkTrafficGraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Download ↓"
                series: "download"
                speed: NetworkDataProvider.downloadSpeed
                traceColor: Theme.accent
            }
            NetworkTrafficGraph {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Upload ↑"
                series: "upload"
                speed: NetworkDataProvider.uploadSpeed
                traceColor: Theme.info
            }
        }
    }
    component Label: Text {
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: Theme.fontSizeSm
        textFormat: Text.PlainText
    }
}
