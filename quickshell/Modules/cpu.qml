import ".."
import QtQuick

BaseModule {
    id: cpuModule

    // moduleIcon: ""
    // moduleText: Math.round(PerformanceDataProvider.cpuUsage) + "%"
    widgetId: "cpu"
    textWidth: Theme.fontSizeBase * 2
    Component.onCompleted: Qt.callLater(() => {
        return PerformanceDataProvider.startPolling();
    })
    Component.onDestruction: PerformanceDataProvider.stopPolling()
    customContents: true

    customComponent: Component {
        Item {
            implicitWidth: contentRow.implicitWidth
            implicitHeight: contentRow.implicitHeight

            Row {
                id: contentRow

                anchors.centerIn: parent
                spacing: 8

                Item {
                    height: Theme.moduleHeight - 6
                    width: Theme.moduleWidth - 6

                    ProgressCircle {
                        value: PerformanceDataProvider.cpuUsage
                        width: Theme.moduleWidth - 6
                        height: Theme.moduleHeight - 6
                    }

                    // the offset is necessary as a quick fix for centering the icon in the progresscircle,
                    // but will likely not work the same on all systems, themes, or fonts.
                    // TODO: come up with a better fix
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: 1
                        text: ""
                        font.pixelSize: Theme.fontSizeSm
                        font.family: Theme.fontMono
                        color: cpuModule.isPressed ? Theme.baseSolid : Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                Text {
                    text: Math.round(PerformanceDataProvider.cpuUsage) + "%"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeBase
                    width: cpuModule.textWidth
                    font.weight: Font.Bold
                    color: cpuModule.isPressed ? Theme.baseSolid : Theme.subtext1
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

}
