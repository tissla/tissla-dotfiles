import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: mprisModule

    property string screenName: ""
    property string title: "No media playing"
    property string artist: ""
    property string status: "Stopped"
    property string playerIcon: ""

    width: Math.min(mprisRow.width + 16, 400)
    height: 30

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            getMprisProcess.running = true;
        }
    }

    Process {
        id: getMprisProcess

        running: false
        command: ["playerctl", "metadata", "--format", "{{status}}|||{{artist}}|||{{title}}|||{{playerName}}"]

        stdout: StdioCollector {
            onStreamFinished: {
                let parts = text.trim().split("|||");
                if (parts.length >= 4) {
                    mprisModule.status = parts[0];
                    mprisModule.artist = parts[1];
                    mprisModule.title = parts[2];
                    let player = parts[3].toLowerCase();
                    if (player.includes("spotify"))
                        mprisModule.playerIcon = "󰓇";
                    else if (player.includes("firefox") || player.includes("chrome"))
                        mprisModule.playerIcon = "";
                    else
                        mprisModule.playerIcon = "▶";
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("No players found")) {
                    mprisModule.title = "No media";
                    mprisModule.artist = "";
                    mprisModule.status = "Stopped";
                }
            }
        }

    }

    Row {
        id: mprisRow

        anchors.centerIn: parent
        spacing: 8

        Text {
            text: mprisModule.status === "Playing" ? mprisModule.playerIcon : "⏸"
            font.pixelSize: 20
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: {
                // if (mprisModule.artist)
                //     display = mprisModule.artist + " - " + display;

                if (mprisModule.status === "Stopped")
                    return "No media";

                let display = mprisModule.title;
                return display;
            }
            font.family: Theme.fontMain
            font.pixelSize: 15
            color: Theme.textSecondary
            font.italic: mprisModule.status !== "Playing"
            anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight
            maximumLineCount: 1
        }

    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            playPauseProcess.running = true;
        }
    }

    Process {
        id: playPauseProcess

        running: false
        command: ["playerctl", "play-pause"]
    }

}
