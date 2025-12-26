import "../.."
import QtQuick
import Quickshell
import Quickshell.Io

// BUG: if the system is already producing sound when this
// module starts, the canvas wont be drawn.
// user has to pause all music and restart quickshell/the module
Item {
    id: audiowaveModule

    property var screen: null
    property var fftBars: []
    // sound params
    property real level: 0
    property real frequency: 0
    property real phase: 0
    property real phaseSpeed: 0
    property real wobbleAmp: 0
    property real wobbleFreq: 0
    property real lineThickness: 1
    property real bassFreq: 0
    property real bassAmp: 0

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
        if (totalLevel == 0) {
            // idle animation values
            level = 0.5;
            frequency = 0.04;
            phaseSpeed = 0.05;
            wobbleAmp = 0.08;
            wobbleFreq = 0.2;
            lineThickness = 2;
            bassFreq = 0;
            bassAmp = 0;
        } else {
            // TODO: try to make a wave for each bar and add them together?
            // used for amp on wave1
            level = totalLevel * 0.2 + lowMid * 0.3 + bass * 0.5;
            frequency = highMid * 0.1 + mid * 0.1 + treble * 0.15;
            // phasespeed 0 on play
            phase = 0;
            phaseSpeed = 0;
            // used for amp on wave2
            wobbleAmp = lowMid * 0.01 + mid * 0.09 + highMid * 0.35 + treble * 0.55;
            wobbleFreq = 0.3 * treble / frequency;
            // bass wave
            bassAmp = bass * 0.9 + lowMid * 0.1;
            bassFreq = 0.15 * frequency;
            // thickness from bass
            lineThickness = 2 + bass * 2;
        }
    }

    width: 1200
    height: 40

    Process {
        id: audioBackend

        running: true
        command: [Quickshell.env("HOME") + "/.config/quickshell/AudioBackend/bin/audio-backend"]

        stdout: SplitParser {
            onRead: line => {
                const parts = line.trim().split(";");
                if (parts.length === 0)
                    return;

                audiowaveModule.fftBars = parts.map(p => {
                    return parseFloat(p) || 0;
                });
            }
        }
    }

    Timer {
        interval: 50 // 20 fps
        running: true
        repeat: true
        onTriggered: {
            audiowaveModule.update();
            audiowaveModule.phase += audiowaveModule.phaseSpeed;
            if (audiowaveModule.phase > Math.PI * 10)
                audiowaveModule.phase -= Math.PI * 10;

            canvas.requestPaint();
        }
    }

    Canvas {
        // center line (debug)
        // ctx.beginPath();
        // ctx.strokeStyle = "orange";
        // ctx.lineWidth = 1;
        // ctx.moveTo(width / 2, 0);
        // ctx.lineTo(width / 2, height);
        // ctx.stroke();

        id: canvas

        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            if (!ctx)
                return;

            // GRADIENT FOR LINE STROKE
            let gradient = ctx.createLinearGradient(0, 0, width, 0);
            gradient.addColorStop(0, "transparent");
            gradient.addColorStop(200 / width, Theme.primary);
            gradient.addColorStop(1 - 200 / width, Theme.primary);
            gradient.addColorStop(1, "transparent");
            // canvas ctx
            ctx.clearRect(0, 0, width, height);
            let centerY = height / 2;
            let maxHeight = height * 0.5 - 1;
            ctx.beginPath();
            ctx.strokeStyle = gradient;
            ctx.lineWidth = audiowaveModule.lineThickness;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            // 2step to ease on gpu, can be upped
            let step = 2;
            for (let x = 0; x <= width; x += step) {
                let xFromCenter = x - width / 2;
                // parabola (higher amp toward mid)
                let distFromCenter = Math.abs(xFromCenter);
                let centerFactor = 1 - (distFromCenter / (width / 2));
                centerFactor = centerFactor * centerFactor;
                // total amp from level + centerfactor
                let amplitude = audiowaveModule.level * centerFactor;
                // let wobbleAmp be heavier toward middle
                let wobbleAmpl = audiowaveModule.wobbleAmp * centerFactor;
                // first wave static, phase to center max amp, affected by amp and freq
                let wave1 = Math.sin(xFromCenter * audiowaveModule.frequency - Math.PI / 2 + audiowaveModule.phase) * amplitude;
                // second wave, wobbles on first wave
                let wave2 = Math.sin((xFromCenter * audiowaveModule.wobbleFreq)) * wobbleAmpl;
                // third way with low frequency and high amp
                let wave3 = -Math.sin((xFromCenter * audiowaveModule.bassFreq) - Math.PI / 2) * audiowaveModule.bassAmp;
                // combine
                let combinedWave = wave1 + wave2 + wave3;
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
