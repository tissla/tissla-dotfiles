// DynamicWidget.qml
import QtQuick
import Quickshell

PanelWindow {
    id: dynamicWidget

    required property string widgetId
    required property Component widgetComponent
    required property bool isVisible
    required property int widgetWidth
    required property int widgetHeight
    property int frozenX: 0
    property var screen: WidgetManager.lastScreen || Quickshell.screens[0]

    visible: isVisible
    implicitWidth: widgetWidth
    implicitHeight: widgetHeight
    color: "transparent"
    Component.onCompleted: {
        console.log("[DynamicWidget]", widgetId, "positioned at x:", margins.left);
    }
    onVisibleChanged: {
        if (visible) {
            frozenX = Math.max(10, Math.min(WidgetManager.lastMouseX - (widgetWidth / 2), screen.width - widgetWidth - 20));
            console.log("[DynamicWidget]", widgetId, "on screen:", screen.name, "at x:", frozenX);
        }
    }

    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: 20
        left: frozenX
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
