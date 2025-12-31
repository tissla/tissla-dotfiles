import QtQuick
// WidgetManager.qml
pragma Singleton

QtObject {
    id: widgetManager

    property point position: Qt.point(0, 0)
    property var screenName: null
    property var widgets: ({
    })
    property var moduleRegistry: ({
    })

    // sets the mouse position on the screen. This is used for widget placement
    function setMousePosition(point, scr) {
        widgetManager.position.x = point.x;
        widgetManager.position.y = point.y;
        widgetManager.screenName = scr.name;
        console.log("[WidgetManager] ScreenName set to:", widgetManager.screenName);
    }

    // helper
    function getMousePosition() {
        return position;
    }

    // registers a widget
    function registerWidget(widgetId, widgetRef) {
        widgets[widgetId] = widgetRef;
        console.log("[WidgetManager] Registered widget:", widgetId);
    }

    // registers a module to a widget
    function registerModule(widgetId, moduleRef) {
        if (!moduleRegistry[widgetId])
            moduleRegistry[widgetId] = [];

        moduleRegistry[widgetId].push(moduleRef);
        console.log("[WidgetManager] Registered module for widget:", widgetId, "| Total modules:", moduleRegistry[widgetId].length);
    }

    // toggle widget visibility through the widget register
    function toggleWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = !widgets[widgetId].visible;
        else
            console.log("[WidgetManager] Widget not found:", widgetId);
    }

    // show widget
    function showWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = true;

    }

    // hide widget
    function hideWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = false;

    }

}
