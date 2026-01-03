import "../.."
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
pragma ComponentBehavior: Bound

//TODO: enable menus and clicks
BaseModule {
    id: systemtray

    customContents: true
    // disable baseModules mouse area handling
    enableMouseArea: false

    PanelWindow {
        id: anchorWindow

        height: 0
        width: 0

        anchors {
            left: true
            right: true
            bottom: SettingsManager.barPosition === "bottom"
            top: SettingsManager.barPosition === "top"
        }

    }

    customComponent: Component {
        Row {
            spacing: 8

            Repeater {
                model: SystemTray.items

                delegate: Rectangle {
                    required property var modelData

                    width: Theme.moduleWidth / 2
                    height: Theme.moduleHeight / 2
                    color: "transparent"
                    radius: Theme.radiusAlt

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

        }

    }

}
