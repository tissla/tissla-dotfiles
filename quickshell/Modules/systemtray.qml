import ".."
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

//TODO: enable menus and clicks
BaseModule {
    id: systemtray

    property bool trayToggle: false
    property real t: trayToggle ? 1 : 0

    customContents: true
    // disable baseModules mouse area handling
    enableMouseArea: false

    PanelWindow {
        id: anchorWindow

        implicitHeight: 0
        implicitWidth: 0

        anchors {
            left: true
            right: true
            bottom: SettingsManager.barPosition === "bottom"
            top: SettingsManager.barPosition === "top"
        }

    }

    Behavior on t {
        NumberAnimation {
            duration: 360
            easing.type: Easing.OutCubic
        }

    }

    customComponent: Component {
        Row {
            spacing: Theme.spacingSm * t

            // "closer"
            Rectangle {
                width: Theme.moduleWidth / 2
                height: Theme.moduleHeight / 2
                color: "transparent"
                radius: Theme.radiusAlt
                visible: systemtray.trayToggle
                onVisibleChanged: {
                    if (visible)
                        ccanvas.requestPaint();

                }

                Canvas {
                    id: ccanvas

                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        if (!ctx)
                            return ;

                        const w = width, h = height;
                        // centers
                        const cx = w / 2, cy = h / 2;
                        ctx.reset();
                        ctx.clearRect(0, 0, w, h);
                        ctx.strokeStyle = Theme.primary;
                        ctx.lineWidth = 3;
                        ctx.lineCap = "round";
                        ctx.lineJoin = "round";
                        const angle = Math.PI / 2;
                        ctx.translate(cx, cy);
                        ctx.rotate(angle);
                        ctx.translate(-cx, -cy);
                        // scale
                        const size = Math.min(w, h) * 0.32;
                        // draw
                        ctx.beginPath();
                        ctx.moveTo(cx - size, cy + size * 0.2);
                        ctx.lineTo(cx, cy - size * 0.6);
                        ctx.moveTo(cx + size, cy + size * 0.2);
                        ctx.lineTo(cx, cy - size * 0.6);
                        ctx.stroke();
                    }
                }

            }

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    required property var modelData

                    width: (Theme.moduleWidth / 2) * t
                    height: Theme.moduleHeight / 2
                    color: "transparent"
                    radius: Theme.radiusAlt
                    visible: systemtray.trayToggle

                    Image {
                        id: trayIcon

                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height
                        source: parent.modelData.icon
                        fillMode: Image.PreserveAspectFit
                        Component.onCompleted: {
                            console.log("[SystemTray] rendered icon for:", parent.modelData.id, "path:", parent.modelData.icon);
                        }
                    }

                    MouseArea {
                        id: trayMouseArea

                        preventStealing: true
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                let pos = mapToGlobal(0, height);
                                parent.modelData.display(anchorWindow, pos.x, pos.y);
                            }
                        }
                    }

                }

            }

            Rectangle {
                width: Theme.moduleWidth / 2
                height: Theme.moduleHeight / 2
                color: "transparent"
                radius: Theme.radiusAlt
                visible: true

                Canvas {
                    id: canvas

                    property real tt: systemtray.t

                    onTtChanged: requestPaint()
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        if (!ctx)
                            return ;

                        const w = width, h = height;
                        // centers
                        const cx = w / 2, cy = h / 2;
                        ctx.reset();
                        ctx.clearRect(0, 0, w, h);
                        ctx.strokeStyle = Theme.primary;
                        ctx.lineWidth = 3;
                        ctx.lineCap = "round";
                        ctx.lineJoin = "round";
                        const angle = -Math.PI / 2 * tt;
                        ctx.translate(cx, cy);
                        ctx.rotate(angle);
                        ctx.translate(-cx, -cy);
                        // scale
                        const size = Math.min(w, h) * 0.32;
                        // draw
                        ctx.beginPath();
                        ctx.moveTo(cx - size, cy + size * 0.2);
                        ctx.lineTo(cx, cy - size * 0.6);
                        ctx.moveTo(cx + size, cy + size * 0.2);
                        ctx.lineTo(cx, cy - size * 0.6);
                        ctx.stroke();
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: systemtray.trayToggle = !systemtray.trayToggle
                }

            }

        }

    }

}
