import ".."
import QtQuick

BaseModule {
    id: usbModule

    widgetId: "devices"
    moduleIcon: DevicesDataProvider.controllerIcon
    moduleText: (!DevicesDataProvider.controllerWired && DevicesDataProvider.controllerConnected) ? (DevicesDataProvider.controllerBattery + "%") : ""
}
