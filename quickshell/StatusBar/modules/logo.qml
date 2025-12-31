import "../.."
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

Item {
    property var screen: null

    width: Theme.moduleWidth
    height: Theme.moduleHeight

    Image {
        id: logoImage

        anchors.centerIn: parent
        width: Theme.moduleWidth / 2
        height: Theme.moduleHeight / 2
        source: Quickshell.shellDir + "/Resources/tissla-free.png"
        fillMode: Image.PreserveAspectFit
    }

    ColorOverlay {
        anchors.fill: logoImage
        source: logoImage
        color: Theme.foregroundAlt
    }

}
