import ".."
import QtQuick

BaseWidget {
    id: networkWidget

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

                    // Graph container
                    Rectangle {
                        width: 300
                        height: 200
                        color: "transparent"
                        border.color: Theme.foregroundAlt
                        border.width: 1
                        radius: 4

                        // axle padding
                        Item {
                            id: graphArea

                            anchors.fill: parent
                            anchors.margins: 30
                            anchors.leftMargin: 50
                            anchors.bottomMargin: 30

                            // grid
                            Repeater {
                                model: 5

                                Rectangle {
                                    width: parent.width
                                    height: 1
                                    y: (parent.height / 4) * index
                                    color: Theme.foregroundAlt
                                    opacity: 0.2
                                }

                            }

                            // Y-axel labels
                            Column {
                                anchors.right: parent.left
                                anchors.rightMargin: 10
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                spacing: (parent.height - 60) / 4

                                Repeater {
                                    model: 5

                                    Text {
                                        text: {
                                            let maxSpeed = 1;
                                            let history = NetworkDataProvider.downloadHistory;
                                            for (let i = 0; i < history.length; i++) {
                                                if (history[i] > maxSpeed)
                                                    maxSpeed = history[i];

                                            }
                                            return Math.round(maxSpeed * (4 - index) / 4) + " KB/s";
                                        }
                                        font.pixelSize: 10
                                        color: Theme.foregroundAlt
                                        font.family: Theme.fontMain
                                    }

                                }

                            }

                            //  the graph
                            Canvas {
                                id: networkGraph

                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d");
                                    if (!ctx)
                                        return ;

                                    ctx.clearRect(0, 0, width, height);
                                    let history = NetworkDataProvider.downloadHistory;
                                    if (history.length < 2)
                                        return ;

                                    // find max
                                    let maxSpeed = 1;
                                    for (let i = 0; i < history.length; i++) {
                                        if (history[i] > maxSpeed)
                                            maxSpeed = history[i];

                                    }
                                    // daw line
                                    ctx.beginPath();
                                    ctx.strokeStyle = Theme.primary;
                                    ctx.lineWidth = 2;
                                    ctx.lineJoin = "round";
                                    let stepX = width / Math.max(history.length - 1, 1);
                                    for (let i = 0; i < history.length; i++) {
                                        let x = i * stepX;
                                        let normalizedY = history[i] / maxSpeed;
                                        let y = height - (normalizedY * height);
                                        if (i === 0)
                                            ctx.moveTo(x, y);
                                        else
                                            ctx.lineTo(x, y);
                                    }
                                    ctx.stroke();
                                    // draw fill
                                    ctx.lineTo(width, height);
                                    ctx.lineTo(0, height);
                                    ctx.closePath();
                                    ctx.fillStyle = Theme.primary + "30"; // 30 = 20% opacity
                                    ctx.fill();
                                }

                                Timer {
                                    interval: 5000
                                    running: true
                                    repeat: true
                                    onTriggered: networkGraph.requestPaint()
                                }

                            }

                        }

                        // X-axel label
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            text: "Last hour"
                            font.pixelSize: 10
                            color: Theme.foregroundAlt
                            font.family: Theme.fontMain
                        }

                        // Y-axel label (flipped)
                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 5
                            text: "Speed"
                            font.pixelSize: 10
                            color: Theme.foregroundAlt
                            font.family: Theme.fontMain
                            rotation: -90
                        }

                    }

                }

            }

        }

    }

}
