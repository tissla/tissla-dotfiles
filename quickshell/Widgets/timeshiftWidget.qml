import ".."
import QtQuick

BaseWidget {
    id: timeshiftWidget

    widgetId: "timeshift"
    widgetWidth: 320
    widgetHeight: 280

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.accent

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingLg
            spacing: Theme.spacingMd

            // Header
            Text {
                text: "Timeshift"
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeLg
                font.weight: Font.Bold
                color: Theme.text
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Icon + relative time
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacingMd

                Text {
                    text: ""
                    font.pixelSize: 56
                    color: TimeshiftDataProvider.hasAccess ? Theme.accent : Theme.warning
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: TimeshiftDataProvider.hasAccess ? TimeshiftDataProvider.formatRelative(TimeshiftDataProvider.lastSnapshotDate) : "No access"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeXl
                    font.weight: Font.Bold
                    color: Theme.text
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            // Status
            Text {
                text: TimeshiftDataProvider.hasAccess ? Qt.formatDateTime(TimeshiftDataProvider.lastSnapshotDate, "yyyy-MM-dd  HH:mm") + (TimeshiftDataProvider.lastSnapshotTag ? "  ·  " + TimeshiftDataProvider.lastSnapshotTag : "") : "Passwordless sudo for 'timeshift --list' required"
                font.family: Theme.fontMain
                font.pixelSize: Theme.fontSizeSm
                color: Theme.subtext1
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // Separator
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.accent
            }

            // Details
            Column {
                width: parent.width
                spacing: Theme.spacingSm
                visible: TimeshiftDataProvider.hasAccess

                // Next snapshot
                Row {
                    width: parent.width

                    Text {
                        text: "Next snapshot:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.subtext1
                        width: parent.width * 0.5
                    }

                    Text {
                        text: TimeshiftDataProvider.formatRelative(TimeshiftDataProvider.nextSnapshotDate)
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: TimeshiftDataProvider.nextSnapshotDate.getTime() < Date.now() ? Theme.warning : Theme.success
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Schedule
                Row {
                    width: parent.width

                    Text {
                        text: "Schedule:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.subtext1
                        width: parent.width * 0.5
                    }

                    Text {
                        text: TimeshiftDataProvider.scheduleLabel
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: Theme.text
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

                // Snapshot count
                Row {
                    width: parent.width

                    Text {
                        text: "Snapshots:"
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        color: Theme.subtext1
                        width: parent.width * 0.5
                    }

                    Text {
                        text: TimeshiftDataProvider.snapshotCount
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: Theme.text
                        width: parent.width * 0.5
                        horizontalAlignment: Text.AlignRight
                    }

                }

            }

        }

    }

}
