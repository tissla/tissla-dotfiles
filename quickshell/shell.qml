import QtQuick
import Quickshell

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

    Variants {
        model: ["Calendar", "CpuRam", "Devices", "Gpu", "Volume"]

        Loader {
            property var modelData

            source: modelData + "/" + modelData + "Widget.qml"
            onLoaded: {
                console.log("Loaded:", modelData);
            }
        }

    }

}
