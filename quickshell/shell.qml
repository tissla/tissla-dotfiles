import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shellRoot

    objectName: "shellRoot"

    // StatusBar
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            implicitHeight: SettingsManager.barHeight
            color: "transparent"

            anchors {
                left: true
                right: true
                bottom: SettingsManager.barPosition === "bottom"
                top: SettingsManager.barPosition === "top"
            }

            StatusBar {
                anchors.fill: parent
                screen: modelData
            }

        }

    }

    // TODO: add to settings instead
    Variants {
        model: ["Calendar", "CpuRam", "Devices", "Gpu", "Volume", "Network"]

        Loader {
            property var modelData

            source: "Widgets/" + modelData + "Widget.qml"
        }

    }

    // Lock system
    LockContext {
        id: lockContext

        onUnlocked: {
            sessionLock.locked = false;
        }
    }

    // session lock
    WlSessionLock {
        id: sessionLock

        locked: false

        WlSessionLockSurface {
            id: lockSurface

            LockSurface {
                anchors.fill: parent
                context: lockContext
                screen: lockSurface.screen
            }

        }

    }

    IpcHandler {
        property bool isLocked: sessionLock.locked

        function lock() {
            sessionLock.locked = true;
            console.log("LOCK");
        }

        target: "lock"
    }

}
