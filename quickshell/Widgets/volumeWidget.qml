import ".."
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

BaseWidget {
    id: root

    widgetWidth: 440
    widgetHeight: 500
    widgetId: "volume"

    component DeviceCard: Rectangle {
        id: card
        required property var node
        readonly property bool selected: node === (node.isSink ? VolumeProvider.sink : VolumeProvider.source)
        readonly property bool muted: node.audio ? node.audio.muted : false
        readonly property int percent: node.audio ? Math.round(node.audio.volume * 100) : 0
        implicitHeight: 110
        radius: Theme.radiusAlt
        color: selected ? Theme.surface1 : Theme.surface0
        border.width: 1
        border.color: selected ? Theme.accent : Theme.surface2

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Text {
                    text: card.node.isSink ? "" : "󰍬"
                    color: card.selected ? Theme.accent : Theme.subtext1
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeLg
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        text: VolumeProvider.deviceName(card.node)
                        elide: Text.ElideRight
                        color: Theme.text
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.bold: true
                        ToolTip.visible: nameHover.hovered
                        ToolTip.text: text
                        HoverHandler {
                            id: nameHover
                        }
                    }
                    Text {
                        text: card.selected ? "Default device" : "Available"
                        color: card.selected ? Theme.accent : Theme.subtext1
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                    }
                }
                Button {
                    id: defaultButton
                    text: card.selected ? "✓" : "Use"
                    enabled: card.node.ready && !card.selected
                    onClicked: VolumeProvider.selectDefault(card.node)
                    implicitWidth: 48
                    implicitHeight: 28
                    contentItem: Text {
                        text: defaultButton.text
                        color: card.selected ? Theme.accent : Theme.text
                        font.family: Theme.fontMain
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: Theme.radiusAlt
                        color: defaultButton.hovered ? Theme.surface2 : "transparent"
                        border.width: card.selected ? 0 : 1
                        border.color: Theme.surface2
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Button {
                    id: muteButton
                    implicitWidth: 32
                    implicitHeight: 30
                    enabled: card.node.ready
                    onClicked: VolumeProvider.toggleNodeMute(card.node)
                    ToolTip.visible: hovered
                    ToolTip.text: card.muted ? "Unmute" : "Mute"
                    contentItem: Text {
                        text: card.node.isSink ? (card.muted ? "󰝟" : "") : (card.muted ? "󰍭" : "󰍬")
                        color: card.muted ? Theme.red : Theme.text
                        font.family: Theme.fontMono
                        font.pixelSize: Theme.fontSizeLg
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: Theme.radiusAlt
                        color: muteButton.hovered ? Theme.surface2 : "transparent"
                    }
                }
                Slider {
                    id: slider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    enabled: card.node.ready
                    value: card.percent
                    onMoved: VolumeProvider.setNodeVolume(card.node, value)
                    background: Rectangle {
                        x: slider.leftPadding
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        width: slider.availableWidth
                        height: 6
                        radius: 3
                        color: Theme.surface2
                        Rectangle {
                            width: slider.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: card.muted ? Theme.muted : Theme.accent
                        }
                    }
                    handle: Rectangle {
                        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                        y: slider.topPadding + slider.availableHeight / 2 - height / 2
                        implicitWidth: 16
                        implicitHeight: 16
                        radius: 8
                        color: slider.pressed ? Theme.accent : Theme.text
                        border.width: 2
                        border.color: Theme.baseSolid
                    }
                }
                Text {
                    Layout.preferredWidth: 40
                    text: card.percent + "%"
                    color: card.muted ? Theme.subtext1 : Theme.text
                    font.family: Theme.fontMono
                    font.pixelSize: Theme.fontSizeSm
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Sound"
                    color: Theme.text
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeLg
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: VolumeProvider.outputs.length + " out · " + VolumeProvider.inputs.length + " in"
                    color: Theme.subtext1
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeSm
                }
            }
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: availableWidth
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                Column {
                    width: parent.width
                    spacing: 10
                    Text {
                        text: "OUTPUT"
                        color: Theme.accent
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                        font.letterSpacing: 1.5
                        font.bold: true
                    }
                    Repeater {
                        objectName: "outputsList"
                        model: VolumeProvider.outputs
                        DeviceCard {
                            required property var modelData
                            node: modelData
                            width: parent.width
                        }
                    }
                    Text {
                        visible: VolumeProvider.outputs.length === 0
                        text: "No output devices connected"
                        color: Theme.subtext1
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                    }
                    Item {
                        width: 1
                        height: 4
                    }
                    Text {
                        text: "INPUT"
                        color: Theme.accent
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                        font.letterSpacing: 1.5
                        font.bold: true
                    }
                    Repeater {
                        objectName: "inputsList"
                        model: VolumeProvider.inputs
                        DeviceCard {
                            required property var modelData
                            node: modelData
                            width: parent.width
                        }
                    }
                    Text {
                        visible: VolumeProvider.inputs.length === 0
                        text: "No input devices connected"
                        color: Theme.subtext1
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                    }
                }
            }
        }
    }
}
