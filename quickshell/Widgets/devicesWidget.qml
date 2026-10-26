pragma ComponentBehavior: Bound
import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseWidget {
    id: devicesWidget
    widgetId: "devices"
    widgetWidth: Math.min(460, screen ? screen.width - 40 : 460)
    widgetHeight: Math.min(screen ? screen.height - 100 : 600,
        94 + Math.max(84, DevicesDataProvider.connectedCount * 86 - 8) + (DevicesDataProvider.errorMessage ? 36 : 0))
    // BaseWidget positions on opening; hotplug can resize an already open popup.
    onWidgetHeightChanged: {
        if (visible && screen && SettingsManager.barPosition === "top")
            yPos = screen.height - widgetHeight - SettingsManager.barHeight - Theme.gap;
    }

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent
        Component.onCompleted: { DevicesDataProvider.activate(this); DevicesDataProvider.refresh(); }
        Component.onDestruction: DevicesDataProvider.deactivate(this)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Devices"
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeXl
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: DevicesDataProvider.connectedCount + " connected"
                    color: Theme.subtext1
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeXs
                }
            }
            Text {
                visible: DevicesDataProvider.errorMessage !== ""
                Layout.fillWidth: true
                text: DevicesDataProvider.errorMessage
                wrapMode: Text.WordWrap
                color: Theme.warning
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeXs
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Text {
                    objectName: "emptyDevices"
                    anchors.centerIn: parent
                    visible: DevicesDataProvider.connectedCount === 0
                    text: DevicesDataProvider.refreshing ? "Checking devices…" : "No connected peripherals"
                    color: Theme.muted
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeSm
                }
                ListView {
                    id: deviceList
                    objectName: "deviceList"
                    anchors.fill: parent
                    model: DevicesDataProvider.devices
                    spacing: 8
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    delegate: Rectangle {
                        id: deviceRow
                        required property var modelData
                        width: deviceList.width - (deviceList.contentHeight > deviceList.height ? 12 : 0)
                        height: 78
                        radius: Theme.radiusAlt
                        color: Theme.surface0
                        readonly property bool hasBattery: modelData.battery !== null
                        readonly property bool lowBattery: hasBattery && modelData.battery <= 20 && !modelData.charging
                        readonly property color batteryColor: lowBattery ? Theme.warning : Theme.accent

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            Text {
                                text: DevicesDataProvider.iconFor(deviceRow.modelData.kind)
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 27
                                Layout.preferredWidth: 32
                                horizontalAlignment: Text.AlignHCenter
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 5
                                Text {
                                    Layout.fillWidth: true
                                    text: deviceRow.modelData.name
                                    textFormat: Text.PlainText
                                    elide: Text.ElideRight
                                    color: Theme.text
                                    font.family: Theme.fontMain
                                    font.pixelSize: Theme.fontSizeSm
                                    font.bold: true
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: DevicesDataProvider.typeLabel(deviceRow.modelData.kind) + " · " + deviceRow.modelData.transport
                                    elide: Text.ElideRight
                                    color: Theme.subtext1
                                    font.family: Theme.fontMain
                                    font.pixelSize: Theme.fontSizeXxs
                                }
                            }
                            ColumnLayout {
                                visible: deviceRow.hasBattery
                                Layout.preferredWidth: 62
                                Layout.minimumWidth: 62
                                Layout.maximumWidth: 62
                                spacing: 7
                                Text {
                                    Layout.alignment: Qt.AlignRight
                                    text: (deviceRow.modelData.charging ? "ϟ " : "") + deviceRow.modelData.battery + "%"
                                    color: deviceRow.batteryColor
                                    font.family: Theme.fontMono
                                    font.pixelSize: Theme.fontSizeXs
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 4
                                    radius: 2
                                    color: Theme.surface2
                                    Rectangle {
                                        height: parent.height
                                        width: parent.width * (deviceRow.modelData.battery || 0) / 100
                                        radius: parent.radius
                                        color: deviceRow.batteryColor
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
