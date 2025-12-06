import "../.."
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire

Item {
    // Animate phase

    id: audiowaveModule

    property var screen: null
    property bool isPlaying: false
    property real amplitude: 0.2
    property real phase: 0
    property real rawLevel: linkTracker[0].audio.volume

    onIsPlayingChanged: {
        amplitude = isPlaying ? amplitude : 0.2;
    }
    onRawLevelChanged: {
        isPlaying = rawLevel > 0.01;
        // mappa volym → amplitude, t.ex. 0.1–1.0
        console.log("Raw Level:", rawLevel);
        amplitude = isPlaying ? Math.min(1, 0.1 + rawLevel * 1.5) : 0.2;
    }
    width: 600
    height: 40
    Component.onCompleted: {
        console.log("=== Pipewire Debug ===");
        console.log("Default sink:", Pipewire.preferredDefaultAudioSink);
        console.log("Sink properties:", Object.keys(Pipewire.preferredDefaultAudioSink));
        if (Pipewire.defaultAudioSink) {
            console.log("Sink volume:", Pipewire.defaultAudioSink.volume);
            console.log("Sink channelVolumes:", Pipewire.preferredDfaultAudioSink.channelVolumes);
            console.log("Sink isMuted:", Pipewire.preferredDefaultAudioSink.isMuted);
        }
    }

    // Lyssna direkt på defaultAudioSink
    Connections {
        function onVolumeChanged() {
            console.log("Volume changed:", Pipewire.preferredDefaultAudioSink.volume);
            audiowaveModule.rawLevel = Pipewire.preferredDefaultAudioSink.volume || 0;
        }

        function onChannelVolumesChanged() {
            if (Pipewire.preferredDefaultAudioSink.channelVolumes && Pipewire.preferredDefaultAudioSink.channelVolumes.length > 0) {
                let avgVol = Pipewire.preferredDefaultAudioSink.channelVolumes.reduce((a, b) => {
                    return a + b;
                }) / Pipewire.preferredDefaultAudioSink.channelVolumes.length;
                console.log("Channel volumes changed, avg:", avgVol);
                audiowaveModule.rawLevel = avgVol;
            }
        }

        target: Pipewire.preferredDefaultAudioSink
    }

    Timer {
        interval: 50
        running: true // Always running for smooth animation
        repeat: true
        onTriggered: {
            audiowaveModule.phase += audiowaveModule.isPlaying ? 0.2 : 0.05;
            if (audiowaveModule.phase > Math.PI * 2)
                audiowaveModule.phase -= Math.PI * 2;

            canvas.requestPaint();
        }
    }

    // Debug Rectangle
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: Theme.primary
        opacity: 0.2
    }

    Canvas {
        id: canvas

        anchors.fill: parent
        visible: true
        Component.onCompleted: {
            console.log("Canvas created, size:", width, "x", height);
        }
        onPaint: {
            var ctx = getContext("2d");
            if (!ctx) {
                console.log("No canvas context!");
                return ;
            }
            ctx.clearRect(0, 0, width, height);
            let centerY = height / 2;
            let maxHeight = height * 0.6;
            // Main wave
            ctx.beginPath();
            ctx.strokeStyle = Theme.primary;
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            for (let x = 0; x <= width; x += 2) {
                let y = centerY + Math.sin((x * 0.05) + audiowaveModule.phase) * maxHeight * audiowaveModule.amplitude;
                if (x === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.stroke();
            // Secondary wave (faded)
            ctx.beginPath();
            ctx.strokeStyle = Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3);
            ctx.lineWidth = 1.5;
            for (let x = 0; x <= width; x += 2) {
                let y = centerY + Math.sin((x * 0.07) + audiowaveModule.phase + Math.PI) * maxHeight * audiowaveModule.amplitude * 0.7;
                if (x === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }

    Behavior on amplitude {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }

    }

}
