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
    property int moduleWidth: contentRow.width + 16

    function onWidgetVisibilityChanged(visible) {
        widgetActive = visible;
    }

    width: moduleWidth
    height: 30

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

        Row {
            id: contentRow

            anchors.centerIn: parent
            spacing: 8
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            Text {
                visible: baseModule.moduleIcon !== ""
                text: baseModule.moduleIcon
                font.pixelSize: 20
                font.family: Theme.fontMain
                width: 20
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: baseModule.moduleText !== ""
                text: baseModule.moduleText
                width: 50
                font.family: Theme.fontMain
                font.pixelSize: 15
                font.weight: Font.Bold
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.foregroundAlt
                anchors.verticalCenter: parent.verticalCenter
            }

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
            if (widgetId)
                WidgetManager.toggleWidget(widgetId);

        }
    }

}
