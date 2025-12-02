import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    // CONTROLLER

    id: shellRoot

    property bool volumeVisible: false
    property bool calendarVisible: false
    property bool cpuRamVisible: false

    objectName: "shellRoot"

    // GPU WIDGET
    PanelWindow {
        id: gpuWindow

        screen: Quickshell.screens[1]
        visible: GpuState.isVisible
        implicitWidth: 320
        implicitHeight: 160
        color: "transparent"

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 20
            right: 600
        }

        GpuWidget {
            anchors.fill: parent
            isVisible: GpuState.isVisible
        }

    }

    IpcHandler {
        function toggle() {
            console.log("IPC: toggle gpu");
            GpuState.toggle();
        }

        function show() {
            GpuState.show();
        }

        function hide() {
            GpuState.hide();
        }

        target: "gpu"
    }

    // CPURAM WIDGET
    PanelWindow {
        id: cpuRamWindow

        screen: Quickshell.screens[0]
        visible: CpuRamState.isVisible
        implicitWidth: 450
        implicitHeight: 200
        color: "transparent"

        anchors {
            bottom: true
            right: true
        }

        margins {
            bottom: 20
            right: 300
        }

        CpuRamWidget {
            anchors.fill: parent
            isVisible: CpuRamState.isVisible
        }

    }

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
            bottom: 20
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
            bottom: 20
            right: 20
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
