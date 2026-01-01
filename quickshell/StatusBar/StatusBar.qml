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
        color: SettingsManager.barTransparentBackground ? "transparent" : Theme.background

        // Left modules container
        Rectangle {
            id: leftContainer

            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            width: leftRow.width
            height: parent.height
            color: "transparent"
            visible: leftRow.children.length > 0
            radius: Theme.radius

            Row {
                id: leftRow

                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Repeater {
                    model: statusBar.config.left

                    Rectangle {
                        color: "transparent"
                        width: loader.item ? loader.item.width : 0
                        height: loader.item ? loader.item.height : 0

                        Loader {
                            id: loader

                            source: "modules/" + modelData + ".qml"
                            // pass screen to the module
                            onLoaded: {
                                item.screen = statusBar.screen;
                            }
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
            width: rightRow.width
            height: parent.height
            color: "transparent"
            visible: rightRow.children.length > 0

            Row {
                id: rightRow

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 8

                Repeater {
                    model: statusBar.config.right

                    Rectangle {
                        color: "transparent"
                        radius: Theme.radius
                        width: rightLoader.item ? rightLoader.item.width : 0
                        height: rightLoader.item ? rightLoader.item.height : 0
                        anchors.verticalCenter: parent.verticalCenter

                        Loader {
                            id: rightLoader

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

}
