import "../.."
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: audiowaveModule

    property var screen: null
    property var fftBars: []
    // sound params
    property real level: 0.2
    property real frequency: 0.05
    property real phase: 0
    property real phaseSpeed: 0.05
    property real wobbleAmp: 0.03
    property real wobbleFreq: 0.05
    property real lineThickness: 2.5

    function update() {
        // Bars 0-4: LOW (0-200 Hz)
        // - kick drums, base
        let bass = (fftBars[0] + fftBars[1] + fftBars[2] + fftBars[3] + fftBars[4]) / 5;
        // Bars 5-7: LOW-MID (250-500 Hz)
        // - guitar, piano, voice(deep)
        let lowMid = (fftBars[5] + fftBars[6] + fftBars[7]) / 3;
        // Bars 8-10: MID (500-2000 Hz)
        // - voice, guitar, snare
        let mid = (fftBars[8] + fftBars[9] + fftBars[10]) / 3;
        // Bars 11-13: HIGH-MID (2000-6000 Hz)
        // voice, guitar, attack, hi-hats
        let highMid = (fftBars[11] + fftBars[12] + fftBars[13]) / 3;
        // Bars 14-15: TREBLE/HIGH (6000-20000 Hz)
        // cymbals and air
        let treble = (fftBars[14] + fftBars[15]) / 2;
        // levels
        let totalLevel = fftBars.reduce((sum, val) => {
            return sum + val;
        }, 0) / fftBars.length;
        // used for amp on wave1
        level = 0.2 + totalLevel * 0.2 + lowMid * 0.2 + bass * 0.8;
        frequency = 0.05 + highMid * 0.08 + mid * 0.1 + treble * 0.12;
        // phasespeed only on wave2
        phaseSpeed = 0.05 + highMid * 0.15 + treble * 0.2;
        // used for amp on wave2
        wobbleAmp = 0.03 + lowMid * 0.01 + mid * 0.05 + highMid * 0.1 + treble * 0.5;
        wobbleFreq = 0.05 + treble * 0.5;
        // thickness from bass
        lineThickness = 2 + bass * 2;
    }

    width: 600
    height: 40

    Process {
        id: audioBackend

        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/AudioBackend/bin/audio-backend"]

        stdout: SplitParser {
            onRead: (line) => {
                const parts = line.trim().split(";");
                if (parts.length === 0)
                    return ;

                audiowaveModule.fftBars = parts.map((p) => {
                    return parseFloat(p) || 0;
                });
            }
        }

    }

    Timer {
        interval: 16 // ~60fps
        running: true
        repeat: true
        onTriggered: {
            audiowaveModule.update();
            audiowaveModule.phase += 0.05;
            if (audiowaveModule.phase > Math.PI * 10)
                audiowaveModule.phase -= Math.PI * 10;

            canvas.requestPaint();
        }
    }

    Canvas {
        id: canvas

        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            if (!ctx)
                return ;

            ctx.clearRect(0, 0, width, height);
            let centerY = height / 2;
            let maxHeight = height * 0.5 - 1;
            ctx.beginPath();
            ctx.strokeStyle = Theme.primary;
            ctx.lineWidth = audiowaveModule.lineThickness;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            for (let x = 0; x <= width; x += 2) {
                let xFromCenter = x - width / 2;
                // parabola (higher amp toward mid)
                let distFromCenter = Math.abs(xFromCenter);
                let centerFactor = 1 - (distFromCenter / (width / 2));
                centerFactor = centerFactor * centerFactor;
                // total amp from level + centerfactor
                let amplitude = audiowaveModule.level * (0.3 + centerFactor * 0.7);
                // let wobbleAmp be heavier toward middle
                let wobbleAmpl = audiowaveModule.wobbleAmp * (0.3 + centerFactor * 0.7);
                // first wave static, no phase, affected by amp and freq
                let wave1 = Math.sin(xFromCenter * audiowaveModule.frequency) * amplitude;
                // second wave, wobbles on first wave
                let wave2 = Math.sin((xFromCenter * audiowaveModule.wobbleFreq * 2) + audiowaveModule.phase) * wobbleAmpl;
                // combine
                let combinedWave = wave1 + wave2;
                // scale to maxHeight
                let y = centerY + (combinedWave * maxHeight);
                // paint
                ctx.lineTo(x, y);
            }
            ctx.stroke();
        }
    }

    Behavior on level {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }

    }

    Behavior on lineThickness {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutCubic
        }

    }

    Behavior on frequency {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutCubic
        }

    }

}
