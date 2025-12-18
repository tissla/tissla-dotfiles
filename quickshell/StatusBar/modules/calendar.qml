import "../.."
import QtQuick
import Quickshell

BaseModule {
    id: calendarModule

    // connect to calendar
    widgetId: "calendar"
    moduleText: Qt.formatDateTime(date.date, "dd MMM")
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    moduleIcon: ""

    SystemClock {
        id: date

        precision: SystemClock.Minutes
    }

}
