import "../.."
import QtQuick

BaseModule {
    // Detect active interface on startup

    id: networkModule

    widgetId: "network"
    customContents: true
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, networkModule);
        console.log("[NetworkModule] Registered with WidgetManager on screen:", screen);
    }

    customComponent: Component {
        Row {
            id: networkRow

            anchors.centerIn: parent
            spacing: 8

            // TODO: add functionality to show wifi/ethernet icon dynamically 󰖩󰖩󰖩
            Text {
                text: {
                    let icon = NetworkDataProvider.nwInterface[0] == 'w' ? "󰖩" : "󰲝";
                    return NetworkDataProvider.connected ? icon : "󰲜";
                }
                font.pixelSize: 20
                color: networkModule.isPressed ? Theme.backgroundSolid : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.fontMain
            }

            Row {
                spacing: 4
                anchors.verticalCenter: parent.verticalCenter
                visible: NetworkDataProvider.connected

                Text {
                    text: NetworkDataProvider.formatSpeed(NetworkDataProvider.downloadSpeed)
                    font.family: Theme.fontMain
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    color: networkModule.isPressed ? Theme.backgroundSolid : Theme.foregroundAlt
                    width: 70
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "↓"
                    font.pixelSize: 20
                    color: networkModule.isPressed ? Theme.backgroundSolid : Theme.primary
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: NetworkDataProvider.formatSpeed(NetworkDataProvider.uploadSpeed)
                    font.family: Theme.fontMain
                    font.pixelSize: 15
                    width: 70
                    font.weight: Font.Bold
                    horizontalAlignment: Text.AlignRight
                    color: networkModule.isPressed ? Theme.backgroundSolid : Theme.foregroundAlt
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "↑"
                    font.pixelSize: 20
                    color: networkModule.isPressed ? Theme.backgroundSolid : Theme.primary
                    font.weight: Font.Bold
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            Text {
                visible: !NetworkDataProvider.connected
                text: "down"
                font.family: Theme.fontMain
                font.pixelSize: 13
                font.weight: Font.Bold
                color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter
            }

        }

    }

}
