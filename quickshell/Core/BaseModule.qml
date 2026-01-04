import ".."
import QtQuick

Item {
    id: baseModule

    // properties
    property var screen: null
    property string widgetId: ""
    property bool widgetActive: false
    property string moduleIcon: ""
    property string moduleText: ""
    // mouse events
    property bool enableMouseArea: true
    property var onScrollCallback: null
    // textWidth can be used to keep dynamic values from altering module position.
    // will default to implicitWidth of the text block if unset
    property int textWidth: 0
    // visual state
    property bool isPressed: widgetActive
    property bool isHovered: false
    // default width
    property int moduleWidth: {
        if (customContents && customLoader.item)
            return customLoader.item.width + 20;

        return contentRow.width + 20;
    }
    // custom params
    property bool customContents: false
    property Component customComponent: null

    function onWidgetVisibilityChanged(visible) {
        widgetActive = visible;
    }

    Component.onCompleted: {
        if (!widgetId || widgetId.length === 0)
            return ;

        WidgetManager.registerModule(widgetId, this);
    }
    width: moduleWidth
    height: Theme.moduleHeight

    // content container
    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusAlt
        color: {
            if (baseModule.isPressed)
                return Theme.primary;

            if (mouseArea.containsMouse)
                return Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.2);

            return "transparent";
        }

        // default layout
        Row {
            id: contentRow

            visible: !baseModule.customContents
            anchors.centerIn: parent
            spacing: Theme.spacingSm

            Text {
                visible: baseModule.moduleIcon !== ""
                text: baseModule.moduleIcon
                font.pixelSize: Theme.fontSizeLg
                width: Theme.spacingLg
                font.family: Theme.fontMain
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: baseModule.moduleText !== ""
                text: baseModule.moduleText
                width: baseModule.textWidth > 0 ? baseModule.textWidth : implicitWidth
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeBase
                font.weight: Font.Bold
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.foregroundAlt
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        // custom layout
        Loader {
            id: customLoader

            anchors.centerIn: parent
            visible: baseModule.customContents
            sourceComponent: baseModule.customComponent
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    // mouse interaction
    MouseArea {
        id: mouseArea

        enabled: baseModule.enableMouseArea
        preventStealing: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: baseModule.isHovered = true
        onExited: baseModule.isHovered = false
        onWheel: (wheel) => {
            let delta = wheel.angleDelta.y / 120;
            if (baseModule.onScrollCallback)
                baseModule.onScrollCallback(delta);

        }
        onClicked: (mouse) => {
            let position = mapToGlobal(moduleWidth / 2, 0);
            WidgetManager.setMousePosition(position, screen);
            WidgetManager.toggleWidget(widgetId);
            console.log("TOGGLING WIDGET", baseModule.widgetId, "ON SCREEN", baseModule.screen);
        }
    }

}
