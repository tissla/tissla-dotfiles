import ".."
import QtQuick

BaseModule {
    id: timeshiftModule

    widgetId: "timeshift"
    moduleIcon: "󰁯"
    moduleText: TimeshiftDataProvider.hasAccess ? TimeshiftDataProvider.moduleSnapshotDate : "N/A"
}
