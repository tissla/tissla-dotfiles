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

    // Only these modules have popups. One movable wrapper is created per ID.
    readonly property var widgetSources: ({
        "battery": "batteryWidget.qml",
        "calendar": "calendarWidget.qml",
        "cpu": "cpuWidget.qml",
        "devices": "devicesWidget.qml",
        "gpu": "gpuWidget.qml",
        "network": "networkWidget.qml",
        "theme": "themeWidget.qml",
        "timeshift": "timeshiftWidget.qml",
        "volume": "volumeWidget.qml"
    })

    function widgetIdsForModules(modules) {
        return modules.filter((id, index) => widgetSources[id] !== undefined && modules.indexOf(id) === index);
    }

    // sets the mouse position on the screen. This is used for widget placement
    function setMousePosition(point, scr) {
        widgetManager.position.x = point.x;
        widgetManager.position.y = point.y;
        widgetManager.screenName = scr.name;
        console.log("[WidgetManager] ScreenName set to:", widgetManager.screenName);
    }

    // registers a widget
    function registerWidget(widgetId, widgetRef) {
        widgets[widgetId] = widgetRef;
        console.log("[WidgetManager] Registered widget:", widgetId);
    }

    // unregisters a widget (call on destruction to avoid leaking dead references)
    function unregisterWidget(widgetId, widgetRef) {
        if (widgets[widgetId] === widgetRef) {
            delete widgets[widgetId];
            console.log("[WidgetManager] Unregistered widget:", widgetId);
        }
    }

    // registers a module to a widget
    function registerModule(widgetId, moduleRef) {
        if (!moduleRegistry[widgetId])
            moduleRegistry[widgetId] = [];

        if (moduleRegistry[widgetId].indexOf(moduleRef) !== -1)
            return;
        moduleRegistry[widgetId].push(moduleRef);
        console.log("[WidgetManager] Registered module for widget:", widgetId, "| Total modules:", moduleRegistry[widgetId].length);
    }

    // unregisters a module (call on destruction to avoid leaking dead references)
    function unregisterModule(widgetId, moduleRef) {
        let list = moduleRegistry[widgetId];
        if (!list)
            return ;

        let idx = list.indexOf(moduleRef);
        if (idx >= 0) {
            list.splice(idx, 1);
            console.log("[WidgetManager] Unregistered module for widget:", widgetId, "| Total modules:", list.length);
        }
        if (list.length === 0)
            delete moduleRegistry[widgetId];
    }

    // toggle widget visibility through the widget register
    function toggleWidget(widgetId) {
        const widget = widgets[widgetId];
        if (!widget)
            return;
        if (widget.visible && widget.screen && widget.screen.name === screenName) {
            widget.visible = false;
        } else {
            // Closing first also clears the old screen's module highlight.
            widget.visible = false;
            widget.visible = true;
        }
    }

    // show widget
    function showWidget(widgetId) {
        const widget = widgets[widgetId];
        if (widget) {
            if (widget.visible && widget.screen && widget.screen.name !== screenName)
                widget.visible = false;
            widget.visible = true;
        }

    }

    // hide widget
    function hideWidget(widgetId) {
        if (widgets[widgetId])
            widgets[widgetId].visible = false;

    }

}
