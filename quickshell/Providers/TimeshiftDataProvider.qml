import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: timeshiftData

    property Timer processTimer
    property Process listProcess
    property Process configProcess
    property date lastSnapshotDate: new Date(0)
    property string lastSnapshotTag: ""
    property int snapshotCount: 0
    property bool hasAccess: true
    property string scheduleLabel: "Unknown"
    property int scheduleIntervalMs: 24 * 60 * 60 * 1000
    property date nextSnapshotDate: new Date(lastSnapshotDate.getTime() + scheduleIntervalMs)
    property string moduleSnapshotDate: formatRelative(lastSnapshotDate)

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

    // Read schedule settings to estimate the next snapshot time
    configProcess: Process {
        running: false
        command: ["cat", "/etc/timeshift/timeshift.json"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let cfg = JSON.parse(text);
                    let enabled = (key) => {
                        return cfg[key] === true || cfg[key] === "true";
                    };
                    if (enabled("schedule_hourly")) {
                        timeshiftData.scheduleIntervalMs = 60 * 60 * 1000;
                        timeshiftData.scheduleLabel = "Hourly";
                    } else if (enabled("schedule_daily")) {
                        timeshiftData.scheduleIntervalMs = 24 * 60 * 60 * 1000;
                        timeshiftData.scheduleLabel = "Daily";
                    } else if (enabled("schedule_weekly")) {
                        timeshiftData.scheduleIntervalMs = 7 * 24 * 60 * 60 * 1000;
                        timeshiftData.scheduleLabel = "Weekly";
                    } else if (enabled("schedule_monthly")) {
                        timeshiftData.scheduleIntervalMs = 30 * 24 * 60 * 60 * 1000;
                        timeshiftData.scheduleLabel = "Monthly";
                    } else {
                        timeshiftData.scheduleLabel = "Unknown";
                    }
                } catch (e) {
                    timeshiftData.scheduleLabel = "Unknown";
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    timeshiftData.scheduleLabel = "Unknown";

            }
        }

    }

    // Fetch snapshot list. Requires passwordless sudo for `timeshift --list`,
    // e.g. a sudoers rule: "<user> ALL=(ALL) NOPASSWD: /usr/bin/timeshift --list"
    listProcess: Process {
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
                    let d = timeshiftData.parseSnapshotDate(m[1]);
                    if (d && (!latest || d.getTime() > latest.getTime())) {
                        latest = d;
                        latestTag = m[2];
                    }
                }
                if (latest) {
                    timeshiftData.lastSnapshotDate = latest;
                    timeshiftData.lastSnapshotTag = latestTag;
                    timeshiftData.snapshotCount = count;
                    timeshiftData.hasAccess = true;
                } else {
                    timeshiftData.hasAccess = false;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0) {
                    console.log("[Timeshift] list error:", text);
                    timeshiftData.hasAccess = false;
                }
            }
        }

    }

    processTimer: Timer {
        running: true
        repeat: true
        interval: 10 * 60 * 1000
        triggeredOnStart: true
        onTriggered: {
            listProcess.running = true;
            configProcess.running = true;
        }
    }

}
