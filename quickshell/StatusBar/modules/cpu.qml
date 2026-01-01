import "../.."
import QtQuick

BaseModule {
    id: cpuModule

    moduleIcon: ""
    moduleText: Math.round(PerformanceDataProvider.cpuUsage) + "%"
    widgetId: "cpuram"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    textWidth: Theme.fontSizeBase * 2
}
