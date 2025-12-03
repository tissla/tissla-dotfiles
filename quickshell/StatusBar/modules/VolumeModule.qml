import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: volumeModule

    property string screenName: ""
    property int volume: 50
    property bool isMuted: false

    width: volumeRow.width + 16
    height: 30

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getVolumeProcess.running = true;
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            let globalPos = mouseArea.mapToItem(null, mouse.x, mouse.y);
            WidgetManager.setMousePosition(globalPos.x);
            VolumeState.toggle();
        }
    }

    Process {
        id: getVolumeProcess

        running: false
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%' && " + "pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes && echo muted || echo unmuted"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    volumeModule.volume = parseInt(lines[0]) || 50;
                    volumeModule.isMuted = lines[1] === "muted";
                }
            }
        }

    }

    Row {
        id: volumeRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: {
                if (volumeModule.isMuted)
                    return "󰝟";

                if (volumeModule.volume > 50)
                    return "";

                if (volumeModule.volume > 0)
                    return "";

                return "󰝟";
            }
            font.pixelSize: 20
            color: volumeModule.isMuted ? Theme.accent : Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: volumeModule.isMuted ? "mute" : volumeModule.volume + "%"
            font.family: Theme.fontMono
            font.pixelSize: 14
            color: Theme.textSecondary
            width: 30
            font.weight: Font.Bold
            anchors.verticalCenter: parent.verticalCenter
        }

    }

}
