import "../.."
// StatusBar/modules/UsbDeviceModule.qml
import QtQuick

Item {
    id: usbModule

    property string screenName: ""

    width: usbRow.width + 16
    height: 30

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
            WidgetManager.setMousePosition(globalPos.x);
            UsbDevState.toggle();
        }
    }

    Row {
        id: usbRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: UsbDevState.controllerIcon
            font.family: Theme.fontMono
            font.weight: Font.Bold
            color: Theme.primary
            font.pixelSize: 20
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: UsbDevState.controllerConnected && !UsbDevState.controllerWired
            text: UsbDevState.controllerBattery + "%"
            font.family: Theme.fontMono
            color: Theme.textSecondary
            width: 30
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
