// DynamicWidget.qml
import QtQuick
import Quickshell

PanelWindow {
    id: dynamicWidget

    // module that this widget belongs to
    property var ownerModule: null
    // id of widget
    required property string widgetId
    // the actual widget component
    required property Component widgetComponent
    // visibility
    required property bool isVisible
    // size params
    required property int widgetWidth
    required property int widgetHeight
    // position data (xpos and screen)
    property int xPos: 0
    property var screen: WidgetManager.lastScreen || Quickshell.screens[0]
    //movement props
    property bool isDragging: false
    property int bottomMargin: 20
    property int dragStartX: 0
    property int dragStartY: 0
    property int widgetStartX: 0
    property int widgetStartBottom: 0

    focusable: true
    visible: isVisible
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    color: "transparent"
    // set position
    onVisibleChanged: {
        // only use WidgetManagers x pos if we dont already have one in memory
        if (visible && xPos === 0) {
            xPos = Math.max(10, Math.min(WidgetManager.lastMouseX - (widgetWidth / 2), screen.width - widgetWidth - 20));
            console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", xPos);
        } else if (visible) {
            console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", xPos);
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
                dynamicWidget.isDragging = true;
                dynamicWidget.dragStartX = mouse.x;
                dynamicWidget.dragStartY = mouse.y;
                dynamicWidget.widgetStartX = dynamicWidget.xPos;
                dynamicWidget.widgetStartBottom = dynamicWidget.bottomMargin;
            }
            onPositionChanged: (mouse) => {
                if (!dynamicWidget.isDragging)
                    return ;

                let dx = mouse.x - dynamicWidget.dragStartX;
                let dy = mouse.y - dynamicWidget.dragStartY;
                dynamicWidget.xPos = dynamicWidget.widgetStartX + dx;
                dynamicWidget.bottomMargin = dynamicWidget.widgetStartBottom - dy;
            }
            onReleased: (mouse) => {
                dynamicWidget.isDragging = false;
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
        bottom: bottomMargin
        left: xPos
    }

    Loader {
        anchors.fill: parent
        sourceComponent: widgetComponent
    }

}
