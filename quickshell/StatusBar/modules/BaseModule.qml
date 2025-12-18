// StatusBar/modules/BaseModule.qml
import "../.."
import QtQuick

Item {
    id: baseModule

    // properties
    property var screen: null
    property string widgetId: ""
    property bool widgetActive: false
    property string moduleIcon: ""
    property string moduleText: ""
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

    width: moduleWidth
    height: 40

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
            spacing: 8

            Text {
                visible: baseModule.moduleIcon !== ""
                text: baseModule.moduleIcon
                font.pixelSize: 18
                width: 20
                font.family: Theme.fontMain
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: baseModule.moduleText !== ""
                text: baseModule.moduleText
                font.family: Theme.fontMain
                font.pixelSize: 15
                font.weight: Font.Bold
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.foregroundAlt
                anchors.verticalCenter: parent.verticalCenter
            }

        }

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

        preventStealing: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: isHovered = true
        onExited: isHovered = false
        onClicked: (mouse) => {
            let position = mapToGlobal(0, 0);
            WidgetManager.setMousePosition(position, screen);
            console.log("TOGGLING WIDGET", widgetId, "ON SCREEN", screen);
            WidgetManager.toggleWidget(widgetId);
        }
    }

}
