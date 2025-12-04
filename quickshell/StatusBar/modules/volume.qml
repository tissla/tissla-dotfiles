import "../.."
import QtQuick
import Quickshell
import Quickshell.Io

BaseModule {
    id: volumeModule

    property int volume: 50
    property bool isMuted: false

    widgetId: "volume"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
        // on initial load
        getVolumeProcess.running = true;
    }
    moduleIcon: {
        if (volumeModule.isMuted)
            return "󰝟";

        if (volumeModule.volume > 50)
            return "";

        if (volumeModule.volume > 0)
            return "";

        return "󰝟";
    }
    moduleText: volumeModule.isMuted ? "mute" : volumeModule.volume + "%"

    Process {
        id: volumeEvents

        running: true
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered 'sink'"]

        stdout: SplitParser {
            onRead: (line) => {
                getVolumeProcess.running = true;
            }
        }

    }

    Process {
        id: getVolumeProcess

        running: false
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%' && " + "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo muted || echo unmuted"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split('\n');
                if (lines.length >= 2) {
                    volumeModule.volume = parseInt(lines[0]) || 50;
                    volumeModule.isMuted = (lines[1] === "muted");
                }
            }
        }

    }

    // test
    MouseArea {
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: console.log("hejhej")
        onWheel: (wheel) => {
            let delta = wheel.angleDelta.y > 0 ? 5 : -5;
            Quickshell.execDetached("pactl", ["set-sink-volume", "@DEFAULT_SINK@", (delta > 0 ? "+" : "") + delta + "%"]);
        }
    }

}
