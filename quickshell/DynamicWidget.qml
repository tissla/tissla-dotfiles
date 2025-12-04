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

    visible: isVisible
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    color: "transparent"
    // debug logging
    Component.onCompleted: {
        console.log("[DynamicWidget]", widgetId, "positioned at x:", margins.left);
    }
    // set position
    onVisibleChanged: {
        if (visible) {
            xPos = Math.max(10, Math.min(WidgetManager.lastMouseX - (widgetWidth / 2), screen.width - widgetWidth - 20));
            console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", xPos);
        }
    }

    anchors {
        bottom: true
        left: true
    }

    // position from left, static on bottom
    // TODO: make dynamic (for example if bar and modules are on top)
    margins {
        bottom: 20
        left: xPos
    }

    Loader {
        anchors.fill: parent
        sourceComponent: widgetComponent
        onLoaded: {
            if (item.hasOwnProperty("isVisible"))
                item.isVisible = Qt.binding(() => {
                return dynamicWidget.isVisible;
            });

        }
    }

}
