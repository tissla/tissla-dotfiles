import "../.."
// StatusBar/modules/devices.qml
import QtQuick

BaseModule {
    id: usbModule

    widgetId: "devices"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    moduleIcon: DevicesDataProvider.controllerIcon
    moduleText: (!DevicesDataProvider.controllerWired && DevicesState.controllerConnected) ? (DevicesDataProvider.controllerBattery + "%") : ""
}
