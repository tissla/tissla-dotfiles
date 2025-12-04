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
    // Visual state
    property bool isPressed: widgetActive
    property bool isHovered: false
    // default
    property int moduleWidth: contentRow.width + 16

    // Callback for when widget visibility changes
    function onWidgetVisibilityChanged(visible) {
        widgetActive = visible;
    }

    // static width for now
    width: moduleWidth
    height: 30

    // Standard content container with visual feedback
    Rectangle {
        anchors.fill: parent
        radius: 10
        color: {
            if (isPressed)
                return Theme.primary;

            if (isHovered)
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
                font.family: Theme.fontMono
                width: 20
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                visible: baseModule.moduleText !== ""
                text: baseModule.moduleText
                width: 50
                font.family: Theme.fontMono
                font.pixelSize: 15
                font.weight: Font.Bold
                color: baseModule.isPressed ? Theme.backgroundSolid : Theme.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    // Standard mouse interaction
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: isHovered = true
        onExited: isHovered = false
        onClicked: (mouse) => {
            if (widgetId) {
                let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
                WidgetManager.setMousePosition(globalPos.x, baseModule.screen);
                // Toggle via WidgetManager instead of direct state
                WidgetManager.toggleWidget(widgetId);
            }
        }
    }

}
