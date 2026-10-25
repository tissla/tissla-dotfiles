pragma ComponentBehavior: Bound
import ".."
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: graph
    required property string title
    required property string series
    required property real speed
    required property color traceColor
    readonly property var samples: NetworkDataProvider.history
    readonly property real peak: samples.reduce((maximum, p) => Math.max(maximum, p[series]), 0)
    readonly property real ceiling: Math.max(1, peak * 1.15)
    color: Theme.surface0
    radius: Theme.radiusAlt
    implicitHeight: 164
    onSamplesChanged: plot.requestPaint()
    onTraceColorChanged: plot.requestPaint()
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6
        RowLayout {
            Layout.fillWidth: true
            Label { text: graph.title; color: graph.traceColor; Layout.fillWidth: true }
            Label { text: NetworkDataProvider.formatSpeed(graph.speed); font.pixelSize: Theme.fontSizeXl; font.bold: true }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Canvas {
                id: plot
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = String(Qt.alpha(graph.traceColor, 0.14));
                    ctx.lineWidth = 1;
                    for (let i = 1; i <= 3; i++) {
                        const y = Math.round((height - 2) * i / 3) + 0.5;
                        ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke();
                    }
                    if (!graph.samples.length) return;
                    const end = graph.samples[graph.samples.length - 1].at;
                    const start = end - NetworkDataProvider.historySeconds * 1000;
                    const xAt = p => Math.max(0, (p.at - start) / (end - start) * (width - 2)) + 1;
                    const yAt = p => height - 2 - p[graph.series] / graph.ceiling * (height - 6);
                    ctx.beginPath();
                    ctx.moveTo(xAt(graph.samples[0]), height - 1);
                    for (const p of graph.samples) ctx.lineTo(xAt(p), yAt(p));
                    ctx.lineTo(xAt(graph.samples[graph.samples.length - 1]), height - 1);
                    ctx.closePath();
                    const fill = ctx.createLinearGradient(0, 0, 0, height);
                    fill.addColorStop(0, String(Qt.alpha(graph.traceColor, 0.28)));
                    fill.addColorStop(1, String(Qt.alpha(graph.traceColor, 0.02)));
                    ctx.fillStyle = fill; ctx.fill();
                    ctx.beginPath();
                    graph.samples.forEach((p, i) => i ? ctx.lineTo(xAt(p), yAt(p)) : ctx.moveTo(xAt(p), yAt(p)));
                    ctx.strokeStyle = String(graph.traceColor); ctx.lineWidth = 2; ctx.stroke();
                    const latest = graph.samples[graph.samples.length - 1];
                    ctx.beginPath(); ctx.arc(xAt(latest), yAt(latest), 2.5, 0, Math.PI * 2);
                    ctx.fillStyle = String(graph.traceColor); ctx.fill();
                }
            }
            Label {
                anchors.centerIn: parent
                visible: graph.samples.length === 0
                text: NetworkDataProvider.connected ? "Collecting samples…" : "No active connection"
                color: Theme.muted
                font.pixelSize: Theme.fontSizeXxs
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Label { text: "3 min"; color: Theme.muted; font.pixelSize: Theme.fontSizeTiny; Layout.fillWidth: true }
            Label { text: "Peak " + NetworkDataProvider.formatSpeed(graph.peak); color: Theme.subtext1; font.pixelSize: Theme.fontSizeTiny }
        }
    }
    component Label: Text {
        color: Theme.text
        font.family: Theme.fontMain
        font.pixelSize: Theme.fontSizeSm
        textFormat: Text.PlainText
    }
}
