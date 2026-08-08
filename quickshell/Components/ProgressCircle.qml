import ".."
import QtQuick

Canvas {
    property real value: 0
    property color circleColor: Theme.accent
    property color bgColor: Theme.mantle
    property real lineWidthRatio: 0.1

    onValueChanged: requestPaint()
    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        var centerX = width / 2;
        var centerY = height / 2;
        var lineWidth = Math.min(width, height) * lineWidthRatio;
        var radius = Math.min(width, height) / 2 - lineWidth / 2;
        var startAngle = -Math.PI / 2;
        var endAngle = 3 * Math.PI / 2;
        // outer circle
        ctx.beginPath();
        ctx.arc(centerX, centerY, radius, startAngle, endAngle);
        ctx.lineWidth = lineWidth;
        ctx.strokeStyle = bgColor;
        ctx.lineCap = "butt";
        ctx.stroke();
        // fill
        if (value > 0) {
            ctx.beginPath();
            var valueAngle = startAngle + (value / 100) * (endAngle - startAngle);
            ctx.arc(centerX, centerY, radius, startAngle, valueAngle);
            ctx.lineWidth = Math.min(width, height) * lineWidthRatio;
            ctx.strokeStyle = circleColor;
            ctx.lineCap = "butt";
            ctx.stroke();
        }
    }
}
