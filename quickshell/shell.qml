import QtQuick
import Quickshell

ShellRoot {
    id: shellRoot

    objectName: "shellRoot"

    // StatusBar
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            implicitHeight: SettingsManager.barHeight
            color: "transparent"

            anchors {
                left: true
                right: true
                bottom: SettingsManager.barPosition === "bottom"
                top: SettingsManager.barPosition === "top"
            }

            StatusBar {
                anchors.fill: parent
                screen: modelData
            }

        }

    }

    // GPU Widget
    DynamicWidget {
        widgetId: "gpu"
        widgetWidth: 340
        widgetHeight: 220
        Component.onCompleted: {
            WidgetManager.registerWidget("gpu", this);
        }

        widgetComponent: Component {
            GpuWidget {
            }

        }

    }

    // CPU/RAM Widget
    DynamicWidget {
        widgetId: "cpuram"
        widgetWidth: 500
        widgetHeight: 220
        Component.onCompleted: {
            WidgetManager.registerWidget("cpuram", this);
        }

        widgetComponent: Component {
            CpuRamWidget {
            }

        }

    }

    // Volume Widget
    DynamicWidget {
        widgetId: "volume"
        widgetWidth: 40
        widgetHeight: 200
        Component.onCompleted: {
            WidgetManager.registerWidget("volume", this);
        }

        widgetComponent: Component {
            VolumeWidget {
            }

        }

    }

    // USB Device Widget
    DynamicWidget {
        widgetId: "devices"
        widgetWidth: 200
        widgetHeight: 180
        Component.onCompleted: {
            WidgetManager.registerWidget("devices", this);
        }

        widgetComponent: Component {
            DevicesWidget {
            }

        }

    }

    // calendar
    DynamicWidget {
        widgetId: "calendar"
        widgetWidth: 620
        widgetHeight: 420
        Component.onCompleted: {
            WidgetManager.registerWidget("calendar", this);
        }

        widgetComponent: Component {
            CalendarWidget {
            }

        }

    }

}
