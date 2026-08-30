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

            let wp = WallpaperManager.wallpapers[root.screen.name];
            if (!wp)
                return "";

            return WallpaperManager.wallpapersPath + "/" + wp;
        }
        fillMode: Image.PreserveAspectCrop
        cache: true
    }

    // weather
    Item {
        id: weatherInfo

        property date latestUpdate
        property string temp: ""
        property string icon: ""
        property string wText: ""
        property var futureWeatherPoints: []
        property bool dataReceived: false

        anchors.fill: parent
        visible: (SettingsManager.isPrimary(root.screen.name) || Quickshell.screens.length === 1) && dataReceived
        Component.onCompleted: {
            WeatherDataProvider.weatherDataReady.connect(function (data) {
                let current = data[0];
                weatherInfo.temp = current.temp;
                weatherInfo.icon = current.icon;
                weatherInfo.wText = current.wText;
                weatherInfo.latestUpdate = current.latestUpdate;
                weatherInfo.futureWeatherPoints = data.slice(1);
                weatherInfo.dataReceived = true;
            });
            // start timer
            weatherUpdateTimer.running = true;
        }

        Timer {
            id: weatherUpdateTimer

            // 60 min
            interval: 1000 * 60 * 60
            running: false
            triggeredOnStart: true
            repeat: true
            onTriggered: {
                WeatherDataProvider.getWeatherData();
            }
        }
        Rectangle {
            id: weatherCard
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 200
            anchors.topMargin: 200
            width: weatherColumn.implicitWidth
            height: weatherColumn.implicitHeight
            radius: Theme.radius
            // color: Qt.rgba(0, 0, 0, 0.35)
            color: "transparent"
            Column {
                id: weatherColumn
                padding: 30
                Row {
                    spacing: 50

                    Column {
                        spacing: 0

                        Text {
                            id: weatherInfoTime

                            text: Qt.formatDateTime(weatherInfo.latestUpdate, "hh:mm")
                            color: Theme.subtext1
                            font.pixelSize: 30
                            font.family: Theme.fontMain
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.6)
                        }
                        // Temp

                        Text {
                            id: weatherInfoTemp

                            text: weatherInfo.temp + " °C"
                            color: Theme.subtext1
                            font.pixelSize: 40
                            font.family: Theme.fontMain
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.6)
                        }

                        Text {
                            id: weatherInfoText

                            text: weatherInfo.wText
                            color: Theme.subtext1
                            font.pixelSize: 20
                            font.family: Theme.fontMain
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.6)
                        }
                    }
                    // Icon

                    Item {
                        width: 140
                        height: parent.height

                        Text {
                            id: weatherInfoIcon

                            text: weatherInfo.icon
                            color: Theme.subtext1
                            font.pixelSize: 130
                            font.family: Theme.fontMain
                            anchors.centerIn: parent
                            style: Text.Outline
                            styleColor: Qt.rgba(0, 0, 0, 0.6)
                        }
                    }
                }

                // future weather
                Row {
                    topPadding: 20
                    spacing: 20

                    Repeater {
                        model: weatherInfo.futureWeatherPoints

                        Row {
                            width: childrenRect.width
                            height: childrenRect.height
                            spacing: 20

                            Column {
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: 100

                                //weatherdata
                                Text {
                                    text: Qt.formatDateTime(modelData.latestUpdate, "hh:mm")
                                    color: Theme.subtext1
                                    font.pixelSize: 18
                                    font.family: Theme.fontMain
                                    style: Text.Outline
                                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                                    width: parent.width
                                    horizontalAlignment: Text.AlignHCenter
                                }

                                Text {
                                    //icon
                                    text: modelData.icon
                                    color: Theme.subtext1
                                    font.pixelSize: 34
                                    font.family: Theme.fontMain
                                    style: Text.Outline
                                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.wText
                                    color: Theme.subtext1
                                    font.pixelSize: 12
                                    font.family: Theme.fontMain
                                    font.italic: true
                                    style: Text.Outline
                                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                }

                                Text {
                                    text: modelData.temp + " °C"
                                    color: Theme.subtext1
                                    font.pixelSize: 20
                                    font.family: Theme.fontMain
                                    style: Text.Outline
                                    styleColor: Qt.rgba(0, 0, 0, 0.6)
                                    horizontalAlignment: Text.AlignHCenter
                                    width: parent.width
                                }
                            }

                            Item {
                                width: 40
                                height: parent.height
                            }
                        }
                    }
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
                interval: 60000
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
                color: Theme.subtext1
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
                color: Theme.subtext1
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
            id: noText

            property real shake: root.context.showFailure ? 4 * Math.PI : 0
            property real ampl: root.context.showFailure ? 0 : 50
            property real rotate: root.context.authPending ? 0 : 360

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: Math.sin(shake) * ampl
            // 0 == 0
            // pi / 2 == 0 > 1 == ampl = 50
            // pi ==  -0 == ampl = 0
            // pi* 3/2 == ampl = -50
            // 2*pi == 0
            anchors.top: parent.verticalCenter
            anchors.topMargin: -20
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.6)
            visible: root.context.showFailure || root.context.authPending
            text: root.context.authPending ? "" : ""
            rotation: root.context.authPending ? rotate : 0
            color: Theme.warning
            font.pixelSize: 150

            Behavior on rotate {
                NumberAnimation {
                    duration: 2000
                    easing.type: Easing.Linear
                }
            }

            Behavior on shake {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.OutCubic
                }
            }

            Behavior on ampl {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.Linear
                }
            }
        }
    }
}
