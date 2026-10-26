pragma ComponentBehavior: Bound
import ".."
import QtQuick

BaseModule {
    id: devicesModule
    widgetId: "devices"
    Component.onCompleted: DevicesDataProvider.activate(devicesModule)
    Component.onDestruction: DevicesDataProvider.deactivate(devicesModule)

    customContents: true
    customComponent: Component {
        Row {
            spacing: 7
            Text {
                text: "󰾰"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeLg
                color: devicesModule.isPressed ? Theme.baseSolid : Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: DevicesDataProvider.connectedCount + (DevicesDataProvider.errorMessage ? " !" : "")
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeSm
                font.bold: true
                color: devicesModule.isPressed ? Theme.baseSolid : Theme.subtext1
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                visible: DevicesDataProvider.lowBatteryCount > 0
                text: "󰁻 " + DevicesDataProvider.lowestBattery + "%"
                font.family: Theme.fontMono
                font.pixelSize: Theme.fontSizeXs
                color: devicesModule.isPressed ? Theme.baseSolid : Theme.warning
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
