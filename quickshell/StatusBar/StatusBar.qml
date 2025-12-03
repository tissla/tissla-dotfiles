import ".."
import QtQuick

Item {
    id: statusBar

    property string screenName: ""
    property var config: SettingsManager.getScreenConfig(screenName)

    Component.onCompleted: {
        console.log("=== StatusBar Created ===");
        console.log("Screen name:", screenName);
    }

    Rectangle {
        anchors.fill: parent
        // change to variable
        color: Qt.rgba(0.118, 0.106, 0.161, 0.5)

        Row {
            anchors.fill: parent
            anchors.margins: 2
            spacing: 0

            // Left modules container
            Rectangle {
                id: leftContainer

                width: leftRow.width + 10
                height: parent.height
                color: Theme.backgroundAlt
                radius: 20
                visible: leftRow.children.length > 0

                Row {
                    id: leftRow

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    spacing: 4

                    Repeater {
                        model: statusBar.config.left

                        Loader {
                            source: "modules/" + modelData + ".qml"
                            // pass screenName to the module
                            onLoaded: {
                                item.screenName = statusBar.screenName;
                            }
                        }

                    }

                }

            }

            // Center modules container
            Item {
                width: parent.width - leftContainer.width - rightContainer.width
                height: parent.height

                Row {
                    anchors.centerIn: parent
                    // offset to get the real center
                    anchors.horizontalCenterOffset: rightContainer.width - leftContainer.width
                    spacing: 4

                    Repeater {
                        model: statusBar.config.center

                        Loader {
                            source: "modules/" + modelData + ".qml"
                        }

                    }

                }

            }

            // Right modules container
            Rectangle {
                id: rightContainer

                width: rightRow.width + 10
                height: parent.height
                color: Theme.backgroundAlt
                radius: 20
                visible: rightRow.children.length > 0

                Row {
                    id: rightRow

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    spacing: 4

                    Repeater {
                        model: statusBar.config.right

                        Loader {
                            source: "modules/" + modelData + ".qml"
                        }

                    }

                }

            }

        }

    }

}
