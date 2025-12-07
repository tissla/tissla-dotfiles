import ".."
import QtQuick

Item {
    id: statusBar

    property var screen: null
    property var config: SettingsManager.getScreenConfig(screen.name)

    Component.onCompleted: {
        console.log("[StatusBar] === StatusBar Created ===");
        console.log("[StatusBar] Screen name:", screen.name);
    }

    Rectangle {
        anchors.fill: parent
        // TODO: change to variable
        color: Qt.rgba(0.118, 0.106, 0.161, 0.5)

        // Left modules container
        Rectangle {
            id: leftContainer

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            width: leftRow.width
            height: parent.height
            color: Theme.backgroundAltSolid
            radius: 15
            visible: leftRow.children.length > 0

            Row {
                id: leftRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Repeater {
                    model: statusBar.config.left

                    Loader {
                        source: "modules/" + modelData + ".qml"
                        // pass screen to the module
                        onLoaded: {
                            item.screen = statusBar.screen;
                        }
                    }

                }

            }

        }

        // Center modules container
        Item {
            width: parent.width - leftContainer.width - rightContainer.width
            height: parent.height
            anchors.centerIn: parent

            Row {
                // offset to get the real center
                spacing: 4
                anchors.centerIn: parent

                Repeater {
                    model: statusBar.config.center

                    Loader {
                        source: "modules/" + modelData + ".qml"
                        onLoaded: {
                            item.screen = statusBar.screen;
                        }
                    }

                }

            }

        }

        // Right modules container
        Rectangle {
            id: rightContainer

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            // space for 5 padding on either side
            width: rightRow.width + 10
            height: parent.height
            color: Theme.backgroundAltSolid
            radius: 15
            visible: rightRow.children.length > 0

            Row {
                id: rightRow

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.leftMargin: 5
                spacing: 4

                Repeater {
                    model: statusBar.config.right

                    Loader {
                        source: "modules/" + modelData + ".qml"
                        onLoaded: {
                            item.screen = statusBar.screen;
                        }
                    }

                }

            }

        }

    }

}
