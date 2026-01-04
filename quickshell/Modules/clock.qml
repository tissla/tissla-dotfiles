import ".."
import QtQuick
import Quickshell

BaseModule {
    id: clockModule

    // connect to calendar
    widgetId: "calendar"
    moduleText: Qt.formatDateTime(clock.date, "hh:mm")
    moduleIcon: ""

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}
