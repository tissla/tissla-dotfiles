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
        isVisible: GpuState.isVisible
        widgetWidth: 320
        widgetHeight: 200

        widgetComponent: Component {
            GpuWidget {
            }

        }

    }

    // CPU/RAM Widget - Dynamic positioning
    DynamicWidget {
        widgetId: "cpuram"
        isVisible: CpuRamState.isVisible
        widgetWidth: 450
        widgetHeight: 200

        widgetComponent: Component {
            CpuRamWidget {
            }

        }

    }

    // Volume Widget - Dynamic positioning
    DynamicWidget {
        widgetId: "volume"
        isVisible: VolumeState.isVisible
        widgetWidth: 40
        widgetHeight: 200

        widgetComponent: Component {
            VolumeWidget {
            }

        }

    }

    // USB Device Widget - Dynamic positioning
    DynamicWidget {
        widgetId: "usbdev"
        isVisible: UsbDevState.isVisible
        widgetWidth: 200
        widgetHeight: 180

        widgetComponent: Component {
            UsbDevWidget {
            }

        }

    }

    // calendar
    DynamicWidget {
        widgetId: "calendar"
        isVisible: CalendarState.isVisible
        widgetWidth: 620
        widgetHeight: 420

        widgetComponent: Component {
            CalendarWidget {
            }

        }

    }

    IpcHandler {
        function toggle() {
            console.log("IPC: toggle usbdev");
            UsbDevState.toggle();
        }

        function show() {
            UsbDevState.show();
        }

        function hide() {
            UsbDevState.hide();
        }

        target: "usbdev"
    }

    IpcHandler {
        function toggle() {
            console.log("IPC: toggle calendar");
            CalendarState.toggle();
        }

        function show() {
            console.log("IPC: show calendar");
            CalendarState.show();
        }

        function hide() {
            console.log("IPC: hide calendar");
            CalendarState.hide();
        }

        target: "calendar"
    }

    IpcHandler {
        function toggle() {
            console.log("IPC: toggle volume");
            VolumeState.toggle();
        }

        function show() {
            console.log("IPC: show volume");
            VolumeState.show();
        }

        function hide() {
            console.log("IPC: hide volume");
            VolumeState.hide();
        }

        target: "volume"
    }

    IpcHandler {
        function toggle() {
            console.log("IPC: toggle cpuram");
            CpuRamState.toggle();
        }

        function show() {
            console.log("IPC: show cpuram");
            CpuRamState.show();
        }

        function hide() {
            console.log("IPC: hide cpuram");
            CpuRamState.hide();
        }

        target: "cpuram"
    }

}
