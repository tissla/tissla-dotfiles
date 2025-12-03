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

        // Left modules container
        Rectangle {
            id: leftContainer

            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: leftRow.width + 10
            height: parent.height
            color: Theme.backgroundAltSolid
            radius: 15
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
            anchors.centerIn: parent

            Row {
                // offset to get the real center
                spacing: 4
                anchors.centerIn: parent

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

            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: rightRow.width + 20
            height: parent.height
            color: Theme.backgroundAltSolid
            radius: 15
            visible: rightRow.children.length > 0

            Row {
                id: rightRow

                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 15
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
