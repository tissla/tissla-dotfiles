import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    // CPU
    // GPU
    // CONTROLLER

    id: shellRoot

    property bool calendarVisible: false

    objectName: shellRoot

    // CALENDAR
    PanelWindow {
        id: calendarWindow

        screen: Quickshell.screens[0]
        visible: CalendarState.isVisible
        implicitWidth: 420
        implicitHeight: 420
        color: "transparent"

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 10
            right: 10
        }

        CalendarWidget {
            anchors.fill: parent
        }

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

}
