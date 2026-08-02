import ".."
import QtQuick

BaseWidget {
    id: volumeWidget

    widgetWidth: 40
    widgetHeight: 200
    widgetId: "volume"

    widgetComponent: Rectangle {
        color: Theme.baseSolid
        radius: 20
        border.width: Theme.borderWidth
        border.color: Theme.accent

        Column {
            anchors.fill: parent

            Item {
                width: parent.width
                height: parent.height

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.margins: 6
                    width: parent.width - 12
                    height: (parent.height - 12) * (VolumeProvider.volume / 100)
                    color: Theme.surface1
                    radius: 20
                }

                MouseArea {
                    function updateVolume(mouseY) {
                        let newVolume = Math.round((1 - mouseY / height) * 100);
                        VolumeProvider.setVolume(newVolume);
                    }

                    anchors.fill: parent
                    onClicked: (mouse) => {
                        return updateVolume(mouse.y);
                    }
                    onPressed: (mouse) => {
                        return updateVolume(mouse.y);
                    }
                    onPositionChanged: (mouse) => {
                        if (pressed)
                            updateVolume(mouse.y);

                    }
                }

            }

        }

    }

}
