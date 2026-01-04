import ".."
import QtQuick

Canvas {
    id: gauge

    property real value: 0
    property real lineWidthRatio: 0.15
    property color gaugeColor: Theme.primary
    property color bgColor: Theme.backgroundAlt

    onValueChanged: requestPaint()
    onGaugeColorChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        var centerX = width / 2;
        var centerY = height / 2;
        var radius = Math.min(width, height) / 2 - 10;
        var startAngle = 0.75 * Math.PI;
        var endAngle = 2.25 * Math.PI;
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, startAngle, endAngle);
        ctx.lineWidth = Math.min(width, height) * lineWidthRatio;
        ctx.strokeStyle = bgColor;
        ctx.lineCap = "round";
        ctx.stroke();
        // fill
        if (value > 0) {
            ctx.beginPath();
            var valueAngle = startAngle + (value / 100) * (endAngle - startAngle);
            ctx.arc(centerX, centerY, radius, startAngle, valueAngle);
            ctx.lineWidth = Math.min(width, height) * lineWidthRatio;
            ctx.strokeStyle = gaugeColor;
            ctx.lineCap = "round";
            ctx.stroke();
        }
        // Center dot
        ctx.beginPath();
        ctx.arc(centerX, centerY, width / 20, 0, 2 * Math.PI);
        ctx.fillStyle = gaugeColor;
        ctx.fill();
        // Needle
        ctx.save();
        ctx.translate(centerX, centerY);
        ctx.rotate(startAngle + (value / 100) * (endAngle - startAngle));
        ctx.beginPath();
        ctx.moveTo(0, 0);
        ctx.lineTo(radius - (width / 6), 0);
        ctx.lineWidth = Math.min(width, height) / 40;
        ctx.strokeStyle = gaugeColor;
        ctx.stroke();
        ctx.restore();
    }
}
