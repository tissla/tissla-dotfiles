import ".."
import QtQuick

BaseModule {
    id: usbModule

    Component.onCompleted: {
        DevicesDataProvider.activate();
    }
    widgetId: "devices"
    moduleIcon: DevicesDataProvider.controllerIcon
    moduleText: (!DevicesDataProvider.controllerWired && DevicesDataProvider.controllerConnected) ? (DevicesDataProvider.controllerBattery + "%") : ""
}
