import ".."
import QtQuick
import Quickshell

Item {
    // the widget wrapper

    id: baseWidget

    property var screen: null
    // id of widget
    required property string widgetId
    // the actual widget component
    required property Component widgetComponent
    // size params
    required property int widgetWidth
    required property int widgetHeight
    // position data
    property int xPos: 0
    property int yPos: Theme.gap
    // panel visibility
    property alias widgetVisible: panel.visible

    Component.onCompleted: {
        WidgetManager.registerWidget(widgetId, panel);
    }

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
                let pos = WidgetManager.getMousePosition();
                console.log("[BaseWidget] MOUSE X POSITION:", pos.x);
                let targetScreen = null;
                for (let i = 0; i < Quickshell.screens.length; i++) {
                    if (Quickshell.screens[i].name === WidgetManager.screenName) {
                        targetScreen = Quickshell.screens[i];
                        break;
                    }
                }
                if (targetScreen) {
                    yPos = SettingsManager.barPosition === "top" ? targetScreen.height - widgetHeight - SettingsManager.barHeight - Theme.gap : Theme.gap;
                    let relativeX = pos.x - targetScreen.x;
                    xPos = Math.max(10, Math.min(relativeX - (widgetWidth / 2), targetScreen.width - widgetWidth - Theme.gap));
                    console.log("Displaying widget on screen:", targetScreen.name, "screen.x:", targetScreen.x, "relative X:", relativeX, "final xPos:", xPos);
                }
            } else {
                yPos = Theme.gap;
            }
            // notify owner(s) about visibility change
            let modules = WidgetManager.moduleRegistry[widgetId];
            if (modules && Array.isArray(modules)) {
                console.log("[BaseWidget] Notifying", modules.length, "modules for", widgetId);
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
