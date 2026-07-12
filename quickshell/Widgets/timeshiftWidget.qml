import ".."
import QtQuick
import Quickshell.Io

BaseWidget {
    id: timeshiftWidget

    widgetId: "timeshift"
    widgetWidth: 320
    widgetHeight: 280

    property date lastSnapshotDate: new Date(0)
    property string lastSnapshotTag: ""
    property int snapshotCount: 0
    property bool hasAccess: true
    property string scheduleLabel: "Unknown"
    property int scheduleIntervalMs: 24 * 60 * 60 * 1000
    property date nextSnapshotDate: new Date(lastSnapshotDate.getTime() + scheduleIntervalMs)

    function parseSnapshotDate(name) {
        let m = name.match(/^(\d{4})-(\d{2})-(\d{2})_(\d{2})-(\d{2})-(\d{2})$/);
        if (!m)
            return null;

        return new Date(parseInt(m[1]), parseInt(m[2]) - 1, parseInt(m[3]), parseInt(m[4]), parseInt(m[5]), parseInt(m[6]));
    }

    function formatRelative(date) {
        if (!date || isNaN(date.getTime()) || date.getTime() === 0)
            return "never";

        let diffMs = Date.now() - date.getTime();
        let future = diffMs < 0;
        let abs = Math.abs(diffMs);
        let mins = Math.floor(abs / 60000);
        let hours = Math.floor(mins / 60);
        let days = Math.floor(hours / 24);
        let label = "";
        if (days > 0)
            label = days + "d";
        else if (hours > 0)
            label = hours + "h";
        else
            label = Math.max(mins, 1) + "m";

        return future ? "in " + label : label + " ago";
    }

    // refresh whenever the popup is opened, plus a slow background poll
    onVisibleChanged: {
        if (visible) {
            listProcess.running = true;
            configProcess.running = true;
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 10 * 60 * 1000
        onTriggered: {
            listProcess.running = true;
            configProcess.running = true;
        }
    }

    // Requires passwordless sudo for `timeshift --list`, e.g. a sudoers rule:
    // "<user> ALL=(ALL) NOPASSWD: /usr/bin/timeshift --list"
    Process {
        id: listProcess

        running: false
        command: ["sudo", "-n", "/usr/bin/timeshift", "--list"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.split("\n");
                let latest = null;
                let latestTag = "";
                let count = 0;
                for (let i = 0; i < lines.length; i++) {
                    if (!lines[i].match(/^\s*\d+/))
                        continue;

                    let m = lines[i].match(/(\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2})\s+(\S*)/);
                    if (!m)
                        continue;

                    count++;
                    let d = timeshiftWidget.parseSnapshotDate(m[1]);
                    if (d && (!latest || d.getTime() > latest.getTime())) {
                        latest = d;
                        latestTag = m[2];
                    }
                }
                if (latest) {
                    timeshiftWidget.lastSnapshotDate = latest;
                    timeshiftWidget.lastSnapshotTag = latestTag;
                    timeshiftWidget.snapshotCount = count;
                    timeshiftWidget.hasAccess = true;
                } else {
                    timeshiftWidget.hasAccess = false;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.log("[Timeshift] list error:", text);
                    timeshiftWidget.hasAccess = false;
                }
            }
        }

    }

    Process {
        id: configProcess

        running: false
        command: ["cat", "/etc/timeshift/timeshift.json"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let cfg = JSON.parse(text);
                    let enabled = (key) => cfg[key] === true || cfg[key] === "true";
                    if (enabled("schedule_hourly")) {
                        timeshiftWidget.scheduleIntervalMs = 60 * 60 * 1000;
                        timeshiftWidget.scheduleLabel = "Hourly";
                    } else if (enabled("schedule_daily")) {
                        timeshiftWidget.scheduleIntervalMs = 24 * 60 * 60 * 1000;
                        timeshiftWidget.scheduleLabel = "Daily";
                    } else if (enabled("schedule_weekly")) {
                        timeshiftWidget.scheduleIntervalMs = 7 * 24 * 60 * 60 * 1000;
                        timeshiftWidget.scheduleLabel = "Weekly";
                    } else if (enabled("schedule_monthly")) {
                        timeshiftWidget.scheduleIntervalMs = 30 * 24 * 60 * 60 * 1000;
                        timeshiftWidget.scheduleLabel = "Monthly";
                    } else {
                        timeshiftWidget.scheduleLabel = "Unknown";
                    }
                } catch (e) {
                    timeshiftWidget.scheduleLabel = "Unknown";
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    timeshiftWidget.scheduleLabel = "Unknown";

            }
        }

    }

    widgetComponent: Rectangle {
        color: Theme.base
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
                    color: timeshiftWidget.hasAccess ? Theme.accent : Theme.warning
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: timeshiftWidget.hasAccess ? timeshiftWidget.formatRelative(timeshiftWidget.lastSnapshotDate) : "No access"
                    font.family: Theme.fontMain
                    font.pixelSize: Theme.fontSizeXl
                    font.weight: Font.Bold
                    color: Theme.text
                    anchors.verticalCenter: parent.verticalCenter
                }

            }

            // Status
            Text {
                text: timeshiftWidget.hasAccess ? Qt.formatDateTime(timeshiftWidget.lastSnapshotDate, "yyyy-MM-dd  HH:mm") + (timeshiftWidget.lastSnapshotTag ? "  ·  " + timeshiftWidget.lastSnapshotTag : "") : "Passwordless sudo for 'timeshift --list' required"
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
                visible: timeshiftWidget.hasAccess

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
                        text: timeshiftWidget.formatRelative(timeshiftWidget.nextSnapshotDate)
                        font.family: Theme.fontMain
                        font.pixelSize: Theme.fontSizeSm
                        font.weight: Font.Bold
                        color: timeshiftWidget.nextSnapshotDate.getTime() < Date.now() ? Theme.warning : Theme.success
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
                        text: timeshiftWidget.scheduleLabel
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
                        text: timeshiftWidget.snapshotCount
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
