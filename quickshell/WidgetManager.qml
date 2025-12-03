import QtQuick
import Quickshell
// WidgetManager.qml
pragma Singleton

QtObject {
    id: widgetManager

    property var lastScreen: null
    // Track last mouse click position
    property int lastMouseX: 0

    function setMousePosition(x, screen) {
        if (!screen) {
            console.log("[WidgetManager] screen is null, returning");
            return ;
        }
        lastMouseX = x;
        lastScreen = screen;
        // calculate previous screens widths
        let previousScreenX = 0;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === screen.name)
                break;

            previousScreenX += Quickshell.screens[i].width;
            console.log("[WidgetManager] checked screen", Quickshell.screens[i].name, "with width", Quickshell.screens[i].width);
        }
        lastMouseX = x + previousScreenX;
        console.log("[WidgetManager] Mouse X position:", x);
    }

}
