// LockSurface.qml
import QtQuick
import Quickshell

Item {
    id: root

    required property var context
    required property var screen

    // wallpapers
    Image {
        anchors.fill: parent
        source: {
            if (!root.screen)
                return "";

            if (root.screen.name === "HDMI-A-1")
                return Quickshell.env("HOME") + "/.config/wallpapers/Anime-Girl-Night-Sky.jpg";

            return Quickshell.env("HOME") + "/.config/wallpapers/MergedSkyVibrantFinal.png";
        }
        fillMode: Image.PreserveAspectCrop
    }

    //TODO: switch to mainscreen
    Item {
        anchors.fill: parent
        visible: root.screen.name === Quickshell.screens[1].name

        // Clock
        Text {
            id: timeLabel

            property var date: new Date()

            text: {
                const hours = this.date.getHours().toString().padStart(2, '0');
                const minutes = this.date.getMinutes().toString().padStart(2, '0');
                return `${hours}:${minutes}`;
            }
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 200
            color: Qt.rgba(1, 1, 1, 0.6)
            font.pixelSize: 200
            font.family: "JetBrains Nerd Font"
            renderType: Text.NativeRendering

            Timer {
                running: true
                repeat: true
                interval: 1000
                onTriggered: timeLabel.date = new Date()
            }

        }

        // Password input
        Rectangle {
            width: 350
            height: 50
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: 80
            color: Qt.rgba(0, 0, 0, 0.4)
            radius: 25
            opacity: passwordInput.text.length > 0 ? 1 : 0
            scale: passwordInput.text.length > 0 ? 1 : 0.9

            TextInput {
                id: passwordInput

                anchors.fill: parent
                anchors.margins: 12
                echoMode: TextInput.Password
                cursorVisible: false
                color: "white"
                font.pixelSize: 16
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                focus: true
                enabled: !root.context.unlockInProgress
                onTextChanged: {
                    root.context.currentText = this.text;
                }
                onAccepted: root.context.tryUnlock()

                Connections {
                    function onCurrentTextChanged() {
                        passwordInput.cursorVisible = false;
                        passwordInput.text = root.context.currentText;
                    }

                    target: root.context
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }

            }

        }

        Text {
            visible: root.context.showFailure
            text: "Incorrect password"
            color: "red"
            font.pixelSize: 14
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: -20
        }

    }

}
