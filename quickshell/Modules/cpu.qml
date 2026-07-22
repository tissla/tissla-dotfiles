import ".."
import QtQuick

BaseModule {
    id: cpuModule

    moduleIcon: ""
    moduleText: Math.round(PerformanceDataProvider.cpuUsage) + "%"
    widgetId: "cpu"
    textWidth: Theme.fontSizeBase * 2
    Component.onCompleted: Qt.callLater(() => PerformanceDataProvider.startPolling())
    Component.onDestruction: PerformanceDataProvider.stopPolling()
}
