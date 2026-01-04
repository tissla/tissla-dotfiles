import ".."
import QtQuick

BaseModule {
    id: gpuModule

    property real gpuUsage: 0

    widgetId: "gpu"
    moduleIcon: "󰢮"
    moduleText: Math.round(GpuDataProvider.gpuUsage) + "%"
    textWidth: Theme.fontSizeBase * 2
}
