pragma ComponentBehavior: Bound
import ".."
import QtQuick

Item {
    id: root
    required property var scene
    required property var screen
    readonly property real viewX: screen ? screen.x : 0
    readonly property real viewY: screen ? screen.y : 0
    clip: true

    function localMeteor(index) {
        const meteor = scene.meteorAt(index);
        return {
            x: meteor.x - viewX,
            y: meteor.y - viewY,
            length: meteor.length,
            opacity: meteor.opacity,
            angle: meteor.angle,
            size: meteor.size
        };
    }
    onViewXChanged: starsCanvas.requestPaint()
    onViewYChanged: starsCanvas.requestPaint()

    function galaxyY(t) {
        const bounds = scene.bounds;
        return bounds.y + bounds.height * (0.94 - 0.86 * t + 0.055 * Math.sin(t * 8));
    }
    function paintGalaxyStars(ctx) {
        const bounds = scene.bounds;
        const random = seed => scene.random(seed + 9000);
        const count = Math.min(12000, Math.round(bounds.width * bounds.height / 650));
        const colors = ["#b8d6ff", "#e0caff", "#ffd9cc", "#e6efff"];
        for (let i = 0; i < count; i++) {
            const t = random(i * 5 + 1100);
            const x = bounds.x + bounds.width * t - viewX;
            const spread = random(i * 5 + 1101) + random(i * 5 + 1102) + random(i * 5 + 1103) - 1.5;
            const y = galaxyY(t) + spread * bounds.height * 0.22 - viewY;
            if (x < -8 || y < -8 || x > width + 8 || y > height + 8)
                continue;
            const brightness = random(i * 5 + 1104);
            ctx.globalAlpha = 0.1 + brightness * 0.55;
            ctx.fillStyle = colors[i % colors.length];
            const size = 0.4 + brightness * 0.9;
            ctx.fillRect(x, y, size, size);
            if (brightness > 0.997) {
                const glow = ctx.createRadialGradient(x, y, 0, x, y, 7);
                glow.addColorStop(0, "#d8eaff");
                glow.addColorStop(0.15, "#79aaff");
                glow.addColorStop(1, "transparent");
                ctx.fillStyle = glow;
                ctx.fillRect(x - 7, y - 7, 14, 14);
            }
        }
        ctx.globalAlpha = 1;
    }

    Rectangle {
        anchors.fill: parent
        color: "#040711"
    }
    Image {
        id: nebulaTexture
        source: root.scene.nebulaSource
        asynchronous: true
        visible: false
    }
    // The software renderer has no ShaderEffect support. Keep a static fallback.
    Image {
        visible: root.GraphicsInfo.api === GraphicsInfo.Software
        x: root.scene.bounds.x - root.viewX
        y: root.scene.bounds.y - root.viewY
        width: root.scene.nebula.width
        height: root.scene.nebula.height
        source: root.scene.nebulaSource
        asynchronous: true
    }
    Loader {
        anchors.fill: parent
        active: root.GraphicsInfo.api !== GraphicsInfo.Software
        sourceComponent: ShaderEffect {
            objectName: "nebulaFlow"
            property var source: nebulaTexture
            property real time: root.scene.elapsedSeconds
            property size worldSize: Qt.size(root.scene.bounds.width, root.scene.bounds.height)
            property point viewportOrigin: Qt.point(root.viewX - root.scene.bounds.x, root.viewY - root.scene.bounds.y)
            property size viewportSize: Qt.size(root.width, root.height)
            property size textureExtent: Qt.size(root.scene.nebula.width, root.scene.nebula.height)
            fragmentShader: "shaders/nebula.frag.qsb"
            // Only the soft gas is downsampled. Stars and text retain full resolution.
            layer.enabled: true
            layer.smooth: true
            layer.textureSize: Qt.size(Math.max(1, Math.ceil(root.width / 2)), Math.max(1, Math.ceil(root.height / 2)))
        }
    }

    // Painted only when the scene, theme or screen geometry changes.
    Canvas {
        id: starsCanvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            root.paintGalaxyStars(ctx);
            for (const star of root.scene.stars) {
                const x = star.x - root.viewX;
                const y = star.y - root.viewY;
                if (x < -2 || y < -2 || x > width + 2 || y > height + 2)
                    continue;
                ctx.globalAlpha = star.opacity;
                ctx.fillStyle = String(Theme.text);
                ctx.beginPath();
                ctx.arc(x, y, star.radius, 0, Math.PI * 2);
                ctx.fill();
            }
            ctx.globalAlpha = 1;
        }
        Connections {
            target: root.scene
            function onStarsChanged() {
                starsCanvas.requestPaint();
            }
        }
        Connections {
            target: Theme
            function onBaseSolidChanged() {
                starsCanvas.requestPaint();
            }
            function onTextChanged() {
                starsCanvas.requestPaint();
            }
        }
    }
    Repeater {
        model: root.scene.meteorCount
        Item {
            id: meteor
            required property int index
            readonly property var position: {
                // One world/time/seed keeps the head and trail continuous across screens.
                const time = root.scene.elapsedSeconds;
                return root.localMeteor(index);
            }
            x: position.x
            y: position.y
            rotation: position.angle
            transformOrigin: Item.TopLeft
            opacity: position.opacity * (0.93 + 0.07 * Math.sin(root.scene.elapsedSeconds * 5.5 + index * 2.7))
            visible: x > -400 && x < root.width + 400 && y > -400 && y < root.height + 400
            Image {
                // The SVG has a soft halo baked into gradients, with its head at (352, 32).
                // All meteors share two small cached textures; no live blur or extra render pass.
                width: meteor.position.length * 384 / 352
                height: 64 * meteor.position.size
                x: -width * 352 / 384
                y: -height / 2
                source: meteor.index % 3 === 0 ? "assets/meteor-ice.svg" : "assets/meteor-ember.svg"
                sourceSize: Qt.size(384, 64)
                smooth: true
            }
        }
    }
}
