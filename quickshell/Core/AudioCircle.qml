import ".."
import QtQuick
import Quickshell

PanelWindow {
    id: audiocirc

    property real freq: 20
    property real phase: 0
    property real amplitude: 3
    // -1 forward, 1 backward
    property real direction: -1

    visible: true
    width: 200
    height: 200

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
                return ;

            // canvas ctx
            ctx.clearRect(0, 0, width, height);
            ctx.beginPath();
            ctx.strokeStyle = Theme.accent;
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            let cx = width / 2;
            let cy = height / 2;
            let padd = 10;
            let r = (Math.min(width, height) / 2) - padd;
            for (let t = 0; t <= Math.PI * 2; t += 0.005) {
                let wobbledR = r + Math.sin(t * freq + phase) * amplitude;
                let x = cx + Math.cos(t) * wobbledR;
                let y = cy + Math.sin(t) * wobbledR;
                if (t === 0)
                    ctx.moveTo(x, y);
                else
                    ctx.lineTo(x, y);
            }
            ctx.closePath();
            ctx.stroke();
        }
    }

    Timer {
        interval: 30 // 62 fps
        running: true
        repeat: true
        onTriggered: {
            audiocirc.phase += audiocirc.direction * 0.1;
            if (audiocirc.phase > Math.PI * 10)
                audiocirc.phase -= Math.PI * 10;
            else if (audiocirc.phase < 0)
                audiocirc.phase += Math.PI * 10;
            canvas.requestPaint();
        }
    }

}
