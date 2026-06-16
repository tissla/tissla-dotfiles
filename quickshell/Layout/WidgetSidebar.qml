import ".."
import QtQuick
import Quickshell

PanelWindow {
    id: sidebar

    property var targetScreen: null
    property var activeModel: []

    screen: targetScreen
    color: "transparent"
    exclusiveZone: 0
    focusable: false
    visible: activeModel.length > 0
    implicitWidth: column.width + Theme.gap * 2
    implicitHeight: column.height + Theme.gap * 2

    anchors {
        right: true
        bottom: true
    }

    margins {
        right: Theme.gap
        bottom: SettingsManager.barPosition === "bottom" ? SettingsManager.barHeight + Theme.gap : Theme.gap
    }

    Connections {
        target: WidgetManager
        function onWidgetToggled(widgetId, screenName, nowActive) {
            if (!sidebar.targetScreen || screenName !== sidebar.targetScreen.name)
                return;
            var m = sidebar.activeModel.slice();
            if (nowActive) {
                m.push(widgetId);
            } else {
                var i = m.indexOf(widgetId);
                if (i >= 0)
                    m.splice(i, 1);
            }
            sidebar.activeModel = m;
        }
    }

    Column {
        id: column

        x: Theme.gap
        y: Theme.gap
        spacing: Theme.gap

        Repeater {
            model: sidebar.activeModel

            delegate: Loader {
                required property var modelData

                source: Quickshell.shellDir + "/Widgets/" + modelData + "Widget.qml"
                onLoaded: {
                    if (item) {
                        item.screen = sidebar.targetScreen;
                        PlaySoundService.playSound("bell");
                    }
                }
            }

        }

    }

}
