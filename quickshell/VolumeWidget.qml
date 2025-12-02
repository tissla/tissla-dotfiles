import QtQuick
import Quickshell.Io

Rectangle {
    id: volumeWidget

    property bool isVisible: false
    property int volume: 50
    property bool isMuted: false

    anchors.fill: parent
    color: Theme.background
    radius: 20
    border.width: 3
    border.color: Theme.primary
    onIsVisibleChanged: {
        if (isVisible)
            getVolumeProcess.running = true;

    }
    Component.onCompleted: {
        getVolumeProcess.running = true;
    }

    Column {
        anchors.fill: parent

        // Vertical slider
        Item {
            width: parent.width
            height: parent.height

            // fill
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 6
                width: parent.width - 12
                height: (parent.height - 12) * (volumeWidget.volume / 100)
                color: Theme.fillClr
                radius: 20

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: parent.radius
                    color: parent.color
                    visible: volumeWidget.volume > parent.radius && volumeWidget.volume < 93
                }

            }

            MouseArea {
                function updateVolume(mouseY) {
                    let newVolume = Math.round((1 - mouseY / height) * 100);
                    newVolume = Math.max(0, Math.min(100, newVolume));
                    volumeWidget.volume = newVolume;
                    setVolumeProcess.volume = newVolume;
                    setVolumeProcess.running = true;
                }

                anchors.fill: parent
                onClicked: (mouse) => {
                    updateVolume(mouse.y);
                }
                onPressed: (mouse) => {
                    updateVolume(mouse.y);
                }
                onPositionChanged: (mouse) => {
                    if (pressed)
                        updateVolume(mouse.y);

                }
            }

        }

    }

    // Process volume inc/dec
    Process {
        id: getVolumeProcess

        running: false
        command: ["pactl", "get-sink-volume", "@DEFAULT_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                let match = text.match(/(\d+)%/);
                if (match)
                    volumeWidget.volume = parseInt(match[1]);

                getMuteProcess.running = true;
            }
        }

    }

    Process {
        id: getMuteProcess

        running: false
        command: ["pactl", "get-sink-mute", "@DEFAULT_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                volumeWidget.isMuted = text.includes("yes");
            }
        }

    }

    Process {
        id: setVolumeProcess

        property int volume: 50

        running: false
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", volume + "%"]
        onRunningChanged: {
            if (!running)
                volumeWidget.volume = volume;

        }
    }

}
