import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: mprisModule

    property var screen: null
    property string title: "No media"
    property string artist: ""
    property string status: "Stopped"

    width: mprisRow.width + 16
    height: 30

    Process {
        id: mprisFollow

        running: true
        command: ["playerctl", "metadata", "--follow", "--format", "{{status}}|||{{artist}}|||{{title}}"]

        stdout: SplitParser {
            onRead: (line) => {
                let parts = line.trim().split("|||");
                if (parts.length >= 3) {
                    mprisModule.status = parts[0];
                    mprisModule.artist = parts[1];
                    mprisModule.title = parts[2];
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("No players found")) {
                    mprisModule.status = "Stopped";
                    mprisModule.title = "No media";
                    mprisModule.artist = "";
                }
            }
        }

    }

    Row {
        id: mprisRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: mprisModule.status === "Playing" ? "▶" : "⏸"
            font.pixelSize: 20
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: mprisModule.status === "Stopped" ? "No media" : mprisModule.title
            font.family: Theme.fontMain
            font.pixelSize: 15
            color: Theme.textSecondary
            elide: Text.ElideRight
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: playPauseProcess.running = true
    }

    Process {
        id: playPauseProcess

        running: false
        command: ["playerctl", "play-pause"]
    }

}
