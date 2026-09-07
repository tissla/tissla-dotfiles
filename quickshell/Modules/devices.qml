import ".."
import QtQuick

BaseModule {
    id: usbModule

    Component.onCompleted: {
        DevicesDataProvider.activate(usbModule);
    }
    Component.onDestruction: DevicesDataProvider.deactivate(usbModule)
    widgetId: "devices"
    moduleIcon: DevicesDataProvider.controllerIcon
    moduleText: (!DevicesDataProvider.controllerWired && DevicesDataProvider.controllerConnected) ? (DevicesDataProvider.controllerBattery + "%") : ""
}
