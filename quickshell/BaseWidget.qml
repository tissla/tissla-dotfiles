import QtQuick
import Quickshell

Item {
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

    Component.onCompleted: {
        WidgetManager.registerWidget(widgetId, panel);
    }
    implicitWidth: screen.width
    implicitHeight: screen.height

    MouseArea {
        id: wrapperArea

        anchors.fill: parent
        hoverEnabled: true
        visible: true
        acceptedButtons: Qt.AllButtons
        onPressed: (mouse) => {
            console.log("Clicked wrapper at", mouse.x, mouse.y);
        }
        onClicked: (mouse) => {
            if (!panel.contains(mouse.x - panel.x, mouse.y - panel.y))
                panel.visible = false;

        }
    }
    // the widget wrapper

    PanelWindow {
        // TODO: instead of callback, use direct x-coordinate somehow
        // reset position on invisible

        id: panel

        visible: false
        focusable: true
        color: "transparent"
        implicitWidth: widgetWidth
        implicitHeight: widgetHeight
        // set position
        onVisibleChanged: {
            if (visible)
                GlobalMouse.requestPosition(function(p) {
                xPos = Math.max(10, Math.min(p.x - (widgetWidth / 2), screen.width - widgetWidth - 20));
                console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", xPos);
            });
            else
                yPos = 20;
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

        // dragging functionality
        Rectangle {
            id: dragHandle

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 30
            color: "transparent"
            z: 100

            MouseArea {
                id: mouseArea

                cursorShape: Qt.OpenHandCursor
                preventStealing: true
                anchors.fill: parent
                hoverEnabled: true
                onPressed: (mouse) => {
                    GlobalMouse.requestPosition(function(p) {
                        baseWidget.isDragging = true;
                        widgetStartX = xPos;
                        widgetStartY = yPos;
                        globalStartX = p.x;
                        globalStartY = p.y;
                        console.log("[DynamicWidget] MousePos: X:", p.x, "| Y:", p.y);
                        console.log("[DynamicWidget] StartDrag: X:", xPos, "| Y:", yPos);
                    });
                }
                onPositionChanged: (mouse) => {
                    if (!baseWidget.isDragging)
                        return ;

                    GlobalMouse.requestPosition(function(p) {
                        const dx = p.x - globalStartX;
                        const dy = p.y - globalStartY;
                        xPos = widgetStartX + dx;
                        yPos = widgetStartY - dy;
                    });
                }
                onReleased: (mouse) => {
                    baseWidget.isDragging = false;
                    console.log("[DynamicWidget] StopDrag: X:", xPos, "| Y:", yPos);
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
