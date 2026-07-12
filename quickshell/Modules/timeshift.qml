import ".."
import QtQuick

BaseModule {
    id: timeshiftModule

    widgetId: "timeshift"
    moduleIcon: "󰁯"
    textWidth: Theme.fontSizeBase * 4
    moduleText: TimeshiftDataProvider.hasAccess ? TimeshiftDataProvider.moduleSnapshotDate : "N/A"
}
