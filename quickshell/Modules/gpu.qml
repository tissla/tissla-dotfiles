import ".."
import QtQuick

BaseModule {
    id: gpuModule

    property real gpuUsage: 0
    property int inset: 6

    widgetId: "gpu"
    moduleIcon: "󰢮"
    moduleText: Math.round(GpuDataProvider.gpuUsage) + "%"
    textWidth: Theme.fontSizeBase * 2
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
                    height: Theme.moduleHeight - inset
                    width: Theme.moduleWidth - inset

                    ProgressCircle {
                        value: GpuDataProvider.gpuUsage
                        width: Theme.moduleWidth - inset
                        height: Theme.moduleHeight - inset
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "󰢮"
                        font.pixelSize: Theme.fontSizeSm
                        font.family: Theme.fontMain
                        color: gpuModule.isPressed ? Theme.baseSolid : Theme.accent
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                Text {
                    text: Math.round(GpuDataProvider.gpuUsage) + "%"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeBase
                    width: gpuModule.textWidth
                    font.weight: Font.Bold
                    color: gpuModule.isPressed ? Theme.baseSolid : Theme.subtext1
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

        }

    }

}
