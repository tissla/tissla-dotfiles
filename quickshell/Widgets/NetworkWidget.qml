import ".."
import QtQuick

BaseWidget {
    id: "networkWidget"

    widgetId: "network"
    widgetWidth: 400
    widgetHeight: 400

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: 3
        border.color: Theme.primary

        Rectangle {
            width: parent.width - 30
            height: parent.height - 30
            color: Theme.backgroundAltSolid
            radius: Theme.radius
            anchors.centerIn: parent

            // main row
            Row {
                anchors.centerIn: parent
                anchors.margins: 20
                spacing: 30

                // first graph
                Column {
                    spacing: 10

                    Canvas {
                        id: networkGraph

                        anchors.fill: parent
                        width: 160
                        height: 160
                        onPaint: {
                            var ctx = getContext("2d");
                            if (!ctx)
                                return ;

                            ctx.clearRect(0, 0, networkGraph.width, networkGraph.height);
                            let history = NetworkDataProvider.downloadHistory;
                            if (history.length < 2)
                                return ;

                            let maxSpeed = Math.max(history, 1);
                            ctx.beginPath();
                            ctx.strokeStyle = Theme.primary;
                            ctx.lineWidth = 3;
                            ctx.lineCap = "round";
                            ctx.lineJoin = "round";
                            let stepX = width / (history.length - 1);
                            for (let i = 0; i <= history.length; i++) {
                                let x = i * stepX;
                                let y = height - (history[i] / maxSpeed * height);
                                if (i === 0)
                                    ctx.moveTo(x, y);
                                else
                                    ctx.lineTo(x, y);
                            }
                            ctx.stroke();
                        }
                    }

                }

            }

        }

    }

}
