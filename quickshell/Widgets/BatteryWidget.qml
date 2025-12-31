import ".."
import QtQuick

BaseWidget {
    id: batteryWidget

    widgetId: "battery"
    widgetWidth: 320
    widgetHeight: 300

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.primary

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            // Header
            Text {
                text: "Battery"
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeLg
                font.weight: Font.Bold
                color: Theme.foreground
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Battery Level Display
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingMd

                Text {
                    text: {
                        let level = BatteryDataProvider.batteryLevel;
                        let charging = BatteryDataProvider.isCharging;
                        if (charging)
                            return "󰂄";

                        if (level >= 80)
                            return "󰁹";

                        if (level >= 60)
                            return "󰂀";

                        if (level >= 40)
                            return "󰁾";

                        if (level >= 20)
                            return "󰁼";

                        return "󰁺";
                    }
                    font.pixelSize: 64
                    color: {
                        if (BatteryDataProvider.isCharging)
                            return Theme.active;

                        if (BatteryDataProvider.batteryLevel <= 20)
                            return Theme.accent;

                        return Theme.primary;
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: BatteryDataProvider.batteryLevel + "%"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeXxl
                    font.weight: Font.Bold
                    color: Theme.foreground
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            // Status
            Text {
                text: BatteryDataProvider.batteryStatus
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeMd
                color: BatteryDataProvider.isCharging ? Theme.active : Theme.foregroundAlt
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.primary
            }

            // Details
            Column {
                width: parent.width
                spacing: Theme.spacingSm

                // Time estimate
                Row {
                    width: parent.width
                    visible: BatteryDataProvider.timeToEmpty > 0 || BatteryDataProvider.timeToFull > 0

                    Text {
                        text: BatteryDataProvider.isCharging ? "Time to full:" : "Time remaining:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.foregroundAlt
                        width: parent.width * 0.5
                    }

                    Text {
                        text: BatteryDataProvider.isCharging ? BatteryDataProvider.formatTime(BatteryDataProvider.timeToFull) : BatteryDataProvider.formatTime(BatteryDataProvider.timeToEmpty)
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: Theme.foreground
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Power draw
                Row {
                    width: parent.width
                    visible: BatteryDataProvider.powerDraw > 0

                    Text {
                        text: BatteryDataProvider.isCharging ? "Charge rate:" : "Power draw:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.foregroundAlt
                        width: parent.width * 0.5
                    }

                    Text {
                        text: BatteryDataProvider.powerDraw.toFixed(2) + " W"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: Theme.foreground
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Health
                Row {
                    width: parent.width

                    Text {
                        text: "Battery health:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.foregroundAlt
                        width: parent.width * 0.5
                    }

                    Text {
                        text: BatteryDataProvider.health + "%"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: {
                            if (BatteryDataProvider.health >= 80)
                                return Theme.active;

                            if (BatteryDataProvider.health >= 60)
                                return Theme.info;

                            return Theme.accent;
                        }
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Capacity
                Row {
                    width: parent.width

                    Text {
                        text: "Capacity:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.foregroundAlt
                        width: parent.width * 0.5
                    }

                    Text {
                        text: BatteryDataProvider.capacity.toFixed(1) + " / " + BatteryDataProvider.capacityDesign.toFixed(1) + " Wh"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                        color: Theme.foreground
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Vendor & Model (bonus info från UPower)
                Row {
                    width: parent.width
                    visible: BatteryDataProvider.battery

                    Text {
                        text: "Model:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                        color: Theme.inactive
                        width: parent.width * 0.5
                    }

                    Text {
                        text: BatteryDataProvider.battery ? (BatteryDataProvider.battery.vendor + " " + BatteryDataProvider.battery.model) : ""
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeXxs
                        color: Theme.inactive
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                        elide: Text.ElideRight
                    }

                }

            }

        }

    }

}
