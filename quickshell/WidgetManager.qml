import QtQuick
// WidgetManager.qml
pragma Singleton

QtObject {
    id: widgetManager

    // Track last mouse click position
    property int lastMouseX: 0

    function setMousePosition(x) {
        lastMouseX = x;
        console.log("[WidgetManager] Mouse X position:", x);
    }

}
