import ".."
import QtQuick
import Quickshell.Io

BaseWidget {
    id: networkWidget

    property Process fetchServerDataProcess
    //TODO: put in env variable
    property string endpoint: "http://192.168.1.240:8099/info"
    property var serverData: []

    function fetchServerData() {
        fetchServerDataProcess.running = true;
    }

    widgetId: "network"
    widgetWidth: 400
    widgetHeight: 400
    onVisibleChanged: {
        if (visible)
            fetchServerData();

    }

    widgetComponent: Rectangle {
        color: Theme.background
        radius: Theme.radius
        border.width: Theme.borderWidth
        border.color: Theme.primary

        Rectangle {
            width: parent.width - 30
            height: parent.height - 30
            color: Theme.surface
            radius: Theme.radius
            anchors.centerIn: parent

            Column {
                width: parent.width - 50
                height: parent.height - 50
                anchors.centerIn: parent

                // header
                Row {
                    Text {
                        text: "NAME"
                        width: 150
                        height: 20
                        color: Theme.foreground
                        font.weight: Font.Bold
                        font.pixelSize: Theme.fontSizeLg
                    }

                    Text {
                        text: "STATUS"
                        width: 150
                        height: 20
                        color: Theme.foreground
                        font.weight: Font.Bold
                        font.pixelSize: Theme.fontSizeLg
                    }

                }

                // spacing
                Rectangle {
                    height: 10
                    width: parent.width
                    color: "transparent"
                }

                Repeater {
                    model: networkWidget.serverData ? networkWidget.serverData.length : 0

                    Rectangle {
                        width: 300
                        height: 24
                        color: index % 2 === 0 ? Theme.background : Theme.backgroundAltSolid

                        Row {
                            anchors.fill: parent
                            anchors.margins: 2

                            Text {
                                text: networkWidget.serverData[index].Name
                                color: Theme.foreground
                                width: 150
                                height: 20
                                font.pixelSize: Theme.fontSizeBase
                            }

                            Text {
                                text: networkWidget.serverData[index].Status
                                color: Theme.foreground
                                width: 150
                                height: 20
                                font.pixelSize: Theme.fontSizeBase
                            }

                        }

                    }

                }

            }

        }

    }

    fetchServerDataProcess: Process {
        running: false
        command: ["curl", "-fsS", networkWidget.endpoint]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    networkWidget.serverData = JSON.parse(text);
                } catch (e) {
                    console.log("JSON parse error:", e, "raw:", text);
                    networkWidget.serverData = [];
                }
            }
        }

    }

}
