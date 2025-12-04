import "../.."
import QtQuick
import Quickshell.Io

Item {
    id: audioModule

    property string screenName: ""
    property bool isPlaying: false
    property real amplitude: 0.2
    property real phase: 0

    width: 200
    height: 30
    Component.onCompleted: {
        console.log("🎵 AudioVisualizer created");
    }
    onIsPlayingChanged: {
        amplitude = isPlaying ? 0.8 : 0.2;
    }

    // Check audio
    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            checkAudioProcess.running = true;
        }
    }

    Process {
        id: checkAudioProcess

        running: false
        command: ["sh", "-c", "pactl list sink-inputs | grep -q 'State: RUNNING' && echo 1 || echo 0"]

        stdout: StdioCollector {
            onStreamFinished: {
                let playing = text.trim() === "1";
                audioModule.isPlaying = playing;
            }
        }

    }

    // Animate phase
    Timer {
        interval: 50
        running: true // Always running for smooth animation
        repeat: true
        onTriggered: {
            audioModule.phase += audioModule.isPlaying ? 0.2 : 0.05;
            if (audioModule.phase > Math.PI * 2)
                audioModule.phase -= Math.PI * 2;

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
                console.log("❌ No canvas context!");
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
                let y = centerY + Math.sin((x * 0.05) + audioModule.phase) * maxHeight * audioModule.amplitude;
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
                let y = centerY + Math.sin((x * 0.07) + audioModule.phase + Math.PI) * maxHeight * audioModule.amplitude * 0.7;
                if (x === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }

    // Debug text
    Text {
        anchors.centerIn: parent
        text: audioModule.isPlaying ? "♪" : "○"
        font.pixelSize: 16
        color: Theme.primary
        opacity: 0.3
        z: -1
    }

    Behavior on amplitude {
        NumberAnimation {
            duration: 300
            easing.type: Easing.InOutCubic
        }

    }

}
