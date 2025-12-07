// Providers/VolumeProvider.qml
import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: volumeData

    property int volume: 50
    property bool isMuted: false
    property Process subscribeProcess
    property Process getVolumeProcess
    property Process setVolumeProcess
    property Process toggleMuteProcess

    function refresh() {
        getVolumeProcess.running = true;
    }

    function setVolume(newVolume) {
        newVolume = Math.max(0, Math.min(100, newVolume));
        setVolumeProcess.volume = newVolume;
        setVolumeProcess.running = true;
    }

    function toggleMute() {
        toggleMuteProcess.running = true;
    }

    Component.onCompleted: {
        refresh();
    }

    subscribeProcess: Process {
        running: true
        command: ["sh", "-c", "pactl subscribe | grep --line-buffered 'sink'"]

        stdout: SplitParser {
            onRead: (line) => {
                volumeData.refresh();
            }
        }

    }

    getVolumeProcess: Process {
        running: false
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%' && " + "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo muted || echo unmuted"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split('\n');
                if (lines.length >= 2) {
                    volumeData.volume = parseInt(lines[0]) || 50;
                    volumeData.isMuted = (lines[1] === "muted");
                }
            }
        }

    }

    setVolumeProcess: Process {
        property int volume: 50

        running: false
        command: ["sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ " + volume + "%"]
        onRunningChanged: {
            if (!running)
                volumeData.refresh();

        }
    }

    toggleMuteProcess: Process {
        running: false
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        onRunningChanged: {
            if (!running)
                volumeData.refresh();

        }
    }

}
