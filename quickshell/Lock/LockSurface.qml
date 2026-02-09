// LockSurface.qml
import ".."
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

            let len = Quickshell.screens.length;
            for (let i = 0; i < len; i++) {
                if (root.screen.name === Quickshell.screens[i].name)
                    return WallpaperManager.wallpapersPath + "/" + WallpaperManager.wallpapers[i % SettingsManager.wallpapers.length];

            }
            // default
            return "";
        }
        fillMode: Image.PreserveAspectCrop
    }

    // weather
    Item {
        id: weatherInfo

        property date latestUpdate
        property string temp: ""
        property string icon: ""
        property string wText: ""

        anchors.fill: parent
        visible: SettingsManager.isPrimary(root.screen.name) || Quickshell.screens.length === 1
        Component.onCompleted: {
            WeatherDataProvider.weatherDataReady.connect(function(data) {
                weatherInfo.temp = data.temp;
                weatherInfo.icon = data.icon;
                weatherInfo.wText = data.wText;
                weatherInfo.latestUpdate = data.latestUpdate;
            });
            WeatherDataProvider.getWeatherData();
        }

        Row {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 200
            anchors.topMargin: 200
            spacing: 30

            Column {
                spacing: 0

                Text {
                    id: weatherInfoTime

                    text: Qt.formatDateTime(weatherInfo.latestUpdate, "hh:mm")
                    color: Theme.foregroundAlt
                    font.pixelSize: 30
                    font.family: Theme.fontMain
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                }
                // Temp

                Text {
                    id: weatherInfoTemp

                    text: weatherInfo.temp + " °C"
                    color: Theme.foregroundAlt
                    font.pixelSize: 40
                    font.family: Theme.fontMain
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                }

                Text {
                    id: weatherInfoText

                    text: weatherInfo.wText
                    color: Theme.foregroundAlt
                    font.pixelSize: 20
                    font.family: Theme.fontMain
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                }

            }
            // Icon

            Item {
                width: 120
                height: parent.height

                Text {
                    id: weatherInfoIcon

                    text: weatherInfo.icon
                    color: Theme.foregroundAlt
                    font.pixelSize: 120
                    font.family: Theme.fontMain
                    anchors.centerIn: parent
                    style: Text.Outline
                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                }

            }

        }

    }

    // date
    Item {
        anchors.fill: parent
        // clock on primary screen only, or show if only one screen available
        visible: SettingsManager.isPrimary(root.screen.name) || Quickshell.screens.length === 1

        // TODO: move params to a config file
        Column {
            // date

            id: dateDisplay

            property var date: new Date()

            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 200
            anchors.bottomMargin: 200
            spacing: 0

            Timer {
                running: true
                repeat: true
                interval: 1000
                onTriggered: dateDisplay.date = new Date()
            }

            // Clock
            Text {
                id: timeLabel

                text: {
                    const hours = dateDisplay.date.getHours().toString().padStart(2, '0');
                    const minutes = dateDisplay.date.getMinutes().toString().padStart(2, '0');
                    return `${hours}:${minutes}`;
                }
                color: Theme.foregroundAlt
                font.pixelSize: 200
                font.family: Theme.fontMain
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.6)
                anchors.left: parent.left
                anchors.bottom: parent.bottom
            }

            // Date
            Text {
                id: dateLabel

                text: Qt.formatDateTime(dateDisplay.date, "d MMMM, yyyy")
                color: Theme.foregroundAlt
                font.pixelSize: 40
                font.family: Theme.fontMain
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.6)
                anchors.left: parent.left
                anchors.top: timeLabel.bottom
                anchors.topMargin: -30
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
