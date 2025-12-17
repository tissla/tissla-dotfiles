import ".."
import QtQuick
import Quickshell

Item {
    // the widget wrapper

    id: baseWidget

    // id of widget
    required property string widgetId
    // the actual widget component
    // size params
    required property Component widgetComponent
    required property int widgetWidth
    required property int widgetHeight
    // position data
    property var screen: WidgetManager.lastScreen || Quickshell.screens[0]
    //movement props
    property bool isDragging: false
    property int xPos: 0
    property int yPos: 20
    // drag state
    property int globalStartX: 0
    property int globalStartY: 0
    property int widgetStartX: 0
    property int widgetStartY: 0
    // panel visibility
    property alias widgetVisible: panel.visible

    Component.onCompleted: {
        WidgetManager.registerWidget(widgetId, panel);
    }
    implicitWidth: screen.width
    implicitHeight: screen.height

    PanelWindow {
        id: panel

        visible: false
        focusable: false
        color: "transparent"
        implicitWidth: widgetWidth
        implicitHeight: widgetHeight
        // set position
        onVisibleChanged: {
            if (visible) {
                let p = WidgetManager.getMousePosition();
                xPos = Math.max(10, Math.min(p.x - (widgetWidth / 2), screen.width - widgetWidth - 20));
                console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", xPos);
            } else {
                yPos = 20;
            }
            // notify owner(s) about visibility change
            let modules = WidgetManager.moduleRegistry[widgetId];
            if (modules && Array.isArray(modules)) {
                console.log("[DynamicWidget] Notifying", modules.length, "modules for", widgetId);
                for (let i = 0; i < modules.length; i++) {
                    if (modules[i] && modules[i].onWidgetVisibilityChanged)
                        modules[i].onWidgetVisibilityChanged(visible);

                }
            }
        }

        anchors {
            bottom: true
            left: true
        }

        // position from left, static on bottom
        // TODO: make dynamic (for example if bar and modules are on top)
        margins {
            bottom: yPos
            left: xPos
        }

        // actual widget logic
        Loader {
            anchors.fill: parent
            sourceComponent: baseWidget.widgetComponent
        }

    }

}
