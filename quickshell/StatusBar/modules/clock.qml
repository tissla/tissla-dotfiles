import "../.."
import QtQuick
import Quickshell

BaseModule {
    id: clockModule

    // connect to calendar
    widgetId: "calendar"
    moduleText: Qt.formatDateTime(clock.date, "hh:mm")
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    moduleIcon: ""
    moduleWidth: 100

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

}
