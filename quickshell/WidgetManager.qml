import QtQuick
import Quickshell
// WidgetManager.qml
pragma Singleton

QtObject {
    id: widgetManager

    // widget registry
    property var widgets: ({
    })
    // module registry
    property var moduleRegistry: ({
    })
    property var lastScreen: null
    // Track last mouse click position
    property int lastMouseX: 0
    property int lastMouseY: 0

    // decides the X-coordinate in which the widget will appear
    // TODO: Use GlobalMouse.qml instead
    function setMousePosition(globalPos, screen) {
        if (!screen) {
            console.log("[WidgetManager] screen is null, returning");
            return ;
        }
        lastMouseX = globalPos.x;
        lastMouseY = globalPos.y;
        lastScreen = screen;
        // calculate previous screens widths
        let previousScreenX = 0;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === screen.name)
                break;

            previousScreenX += Quickshell.screens[i].width;
            console.log("[WidgetManager] checked screen", Quickshell.screens[i].name, "with width", Quickshell.screens[i].width);
        }
        lastMouseX = globalPos.x + previousScreenX;
        console.log("[WidgetManager] Mouse X | Y position:", globalPos.x, " | ", globalPos.y);
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
        // Link module to widget if widget exists
        if (widgets[widgetId])
            widgets[widgetId].ownerModule = moduleRef;

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
