import "../.."
import QtQuick

BaseModule {
    id: gpuModule

    property real gpuUsage: 0

    widgetId: "gpu"
    moduleIcon: "󰢮"
    moduleText: Math.round(GpuDataProvider.gpuUsage) + "%"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
        console.log("[GpuModule] Using GPU vendor:", GpuDataProvider.gpuVendor);
    }
    textWidth: Theme.fontSizeBase * 2
}
