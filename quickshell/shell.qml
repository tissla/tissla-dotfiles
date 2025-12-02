import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    // CPU
    // GPU
    // CONTROLLER

    id: shellRoot

    property bool volumeVisible: false
    property bool calendarVisible: false

    objectName: "shellRoot"

    // VOLUME
    PanelWindow {
        id: volumeWindow

        screen: Quickshell.screens[0]
        visible: VolumeState.isVisible
        implicitWidth: 40
        implicitHeight: 200
        color: "transparent"

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 10
            right: 260
        }

        VolumeWidget {
            anchors.fill: parent
            isVisible: VolumeState.isVisible
        }

    }

    // CALENDAR
    PanelWindow {
        id: calendarWindow

        screen: Quickshell.screens[0]
        visible: CalendarState.isVisible
        implicitWidth: 620
        implicitHeight: 420
        color: "transparent"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

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
            isVisible: CalendarState.isVisible
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

}
