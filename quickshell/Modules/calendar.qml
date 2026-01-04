import ".."
import QtQuick
import Quickshell

BaseModule {
    id: calendarModule

    // connect to calendar
    widgetId: "calendar"
    moduleText: Qt.formatDateTime(date.date, "dd MMM")
    moduleIcon: ""

    SystemClock {
        id: date

        precision: SystemClock.Minutes
    }

}
