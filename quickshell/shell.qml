import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

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

    // GPU Widget - Dynamic positioning
    DynamicWidget {
        widgetId: "gpu"
        widgetWidth: 320
        widgetHeight: 200
        Component.onCompleted: {
            WidgetManager.registerWidget("gpu", this);
        }

        widgetComponent: Component {
            GpuWidget {
            }

        }

    }

    // CPU/RAM Widget - Dynamic positioning
    DynamicWidget {
        widgetId: "cpuram"
        widgetWidth: 450
        widgetHeight: 200
        Component.onCompleted: {
            WidgetManager.registerWidget("cpu", this);
        }

        widgetComponent: Component {
            CpuRamWidget {
            }

        }

    }

    // Volume Widget - Dynamic positioning
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

    // USB Device Widget - Dynamic positioning
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
