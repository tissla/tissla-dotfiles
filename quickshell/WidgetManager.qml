import QtQuick
// WidgetManager.qml
pragma Singleton

QtObject {
    id: widgetManager

    property point position: Qt.point(0, 0)
    property var widgets: ({
    })
    property var moduleRegistry: ({
    })

    function setMousePosition(point) {
        widgetManager.position.x = point.x;
        widgetManager.position.y = point.y;
    }

    function getMousePosition() {
        return position;
    }

    function registerWidget(widgetId, widgetRef) {
        widgets[widgetId] = widgetRef;
        console.log("[WidgetManager] Registered widget:", widgetId);
    }

    function registerModule(widgetId, moduleRef) {
        if (!moduleRegistry[widgetId])
            moduleRegistry[widgetId] = [];

        moduleRegistry[widgetId].push(moduleRef);
        console.log("[WidgetManager] Registered module for widget:", widgetId, "| Total modules:", moduleRegistry[widgetId].length);
    }

    function toggleWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = !widgets[widgetId].visible;
        else
            console.log("[WidgetManager] Widget not found:", widgetId);
    }

    function showWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = true;

    }

    function hideWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = false;

    }

}
