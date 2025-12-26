import QtQuick
import Qt5Compat.GraphicalEffects
import "../.."

Item {

    property var screen: null
    width: 40
    height: 40

    Image {
        id: logoImage

        anchors.centerIn: parent
        width: 20
        height: 20

        source: "/home/tissla/Pictures/logos/tissla-free.png"

        fillMode: Image.PreserveAspectFit
    }
    ColorOverlay {
        anchors.fill: logoImage
        source: logoImage
        color: "#9ca3af"
    }
}
