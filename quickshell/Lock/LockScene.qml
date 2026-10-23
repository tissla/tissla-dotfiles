import ".."
import QtQuick
import Quickshell
import QtQml.WorkerScript

// Shared by every lock surface: one world, one clock, logical screen coordinates.
Item {
    id: root
    property bool active: false
    property var screens: Quickshell.screens
    property real elapsedSeconds: 0
    property double epoch: Date.now()
    readonly property string primaryName: {
        const primary = screens.find(s => SettingsManager.isPrimary(s.name));
        return primary ? primary.name : screens.length ? screens[0].name : "";
    }
    readonly property rect bounds: {
        if (!screens.length)
            return Qt.rect(0, 0, 1, 1);
        const left = Math.min(...screens.map(s => s.x));
        const top = Math.min(...screens.map(s => s.y));
        const right = Math.max(...screens.map(s => s.x + s.width));
        const bottom = Math.max(...screens.map(s => s.y + s.height));
        return Qt.rect(left, top, Math.max(1, right - left), Math.max(1, bottom - top));
    }
    readonly property var stars: {
        const count = Math.min(600, Math.max(100, Math.round(bounds.width * bounds.height / 14000)));
        const points = [];
        for (let i = 0; i < count; i++) {
            points.push({
                x: bounds.x + random(i * 4 + 1) * bounds.width,
                y: bounds.y + random(i * 4 + 2) * bounds.height,
                radius: 0.45 + random(i * 4 + 3) * 1.05,
                opacity: 0.15 + random(i * 4 + 4) * 0.65
            });
        }
        return points;
    }
    readonly property int meteorCount: Math.min(28, Math.max(8, Math.round(bounds.width / 230)))

    property var nebula: ({
            source: "",
            width: 1,
            height: 1
        })
    property string requestedNebulaKey: ""
    readonly property url nebulaSource: nebulaPreload.status === Image.Ready ? nebulaPreload.source : ""

    function prepareNebula() {
        if (!nebulaWorker.ready || !screens.length)
            return;
        const key = bounds.width + "x" + bounds.height;
        if (key === requestedNebulaKey)
            return;
        requestedNebulaKey = key;
        nebulaWorker.sendMessage({
            key: key,
            width: bounds.width,
            height: bounds.height
        });
    }
    Component.onCompleted: Qt.callLater(prepareNebula)
    onBoundsChanged: Qt.callLater(prepareNebula)
    WorkerScript {
        id: nebulaWorker
        source: "Nebula.mjs"
        onReadyChanged: if (ready)
            Qt.callLater(root.prepareNebula)
        onMessage: message => {
            if (message.key === root.requestedNebulaKey)
                root.nebula = {
                    source: String(message.texture.source),
                    width: Number(message.texture.width),
                    height: Number(message.texture.height)
                };
        }
    }
    // Decode before locking too; Image's shared cache retains the decoded texture.
    Image {
        id: nebulaPreload
        source: root.nebula.source
        asynchronous: true
        visible: false
    }

    function random(seed) {
        const value = Math.sin(seed * 127.1 + 311.7) * 43758.5453;
        return value - Math.floor(value);
    }
    function meteorAt(index) {
        const margin = 400;
        const speed = 70 + random(index + 301) * 100;
        const travel = elapsedSeconds * speed;
        const angleDegrees = 20 + random(index + 601) * 10;
        const angle = angleDegrees * Math.PI / 180;
        const spanX = bounds.width + margin * 2;
        const spanY = bounds.height + margin * 2;
        return {
            x: bounds.x - margin + (random(index + 101) * spanX + travel * Math.cos(angle)) % spanX,
            y: bounds.y - margin + (random(index + 201) * spanY + travel * Math.sin(angle)) % spanY,
            angle: angleDegrees,
            size: 0.7 + random(index + 701) * 0.65,
            length: 160 + random(index + 401) * 150,
            opacity: 0.65 + random(index + 501) * 0.3
        };
    }
    onActiveChanged: {
        if (active)
            epoch = Date.now() - elapsedSeconds * 1000;
    }
    Timer {
        interval: 33
        running: root.active
        repeat: true
        onTriggered: root.elapsedSeconds = (Date.now() - root.epoch) / 1000
    }
}
