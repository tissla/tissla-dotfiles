import ".."
import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

BaseModule {
    customContents: true
    width: Theme.moduleWidth
    height: Theme.moduleHeight
    widgetId: "theme"

    customComponent: Component {
        Rectangle {
            Image {
                id: logoImage

                anchors.centerIn: parent
                width: Theme.moduleWidth / 2
                height: Theme.moduleHeight / 2
                source: Quickshell.shellDir + "/Assets/tissla-free.png"
                fillMode: Image.PreserveAspectFit
            }

            ColorOverlay {
                anchors.fill: logoImage
                source: logoImage
                color: Theme.foregroundAlt
            }

        }

    }

}
