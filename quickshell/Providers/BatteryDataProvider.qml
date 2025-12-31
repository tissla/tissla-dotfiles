import QtQuick
import Quickshell.Services.UPower
pragma Singleton

QtObject {
    id: batteryData

    // Find battery device
    property UPowerDevice battery: {
        let devices = UPower.devices;
        for (let i = 0; i < devices.length; i++) {
            if (devices[i].type === UPowerDeviceType.Battery)
                return devices[i];

        }
        return null;
    }
    // Convenience properties
    property bool hasBattery: battery !== null
    property int batteryLevel: battery ? Math.round(battery.percentage) : 0
    property bool isCharging: battery ? battery.state === UPowerDeviceState.Charging : false
    property bool isPlugged: battery ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged) : false
    property string batteryStatus: battery ? getStatusString(battery.state) : "Unknown"
    property int timeToEmpty: battery ? Math.round(battery.timeToEmpty / 60) : -1 // seconds to minutes
    property int timeToFull: battery ? Math.round(battery.timeToFull / 60) : -1 // seconds to minutes
    property real powerDraw: battery ? battery.energyRate : 0 // watts
    property real capacity: battery ? battery.energyFull : 0 // Wh
    property real capacityDesign: battery ? battery.energyFullDesign : 0 // Wh
    property int health: battery && capacityDesign > 0 ? Math.round((capacity / capacityDesign) * 100) : 100

    function getStatusString(state) {
        switch (state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.Empty:
            return "Empty";
        case UPowerDeviceState.FullyCharged:
            return "Fully Charged";
        case UPowerDeviceState.PendingCharge:
            return "Pending Charge";
        case UPowerDeviceState.PendingDischarge:
            return "Pending Discharge";
        default:
            return "Unknown";
        }
    }

    function formatTime(minutes) {
        if (minutes < 0 || minutes === 0)
            return "Unknown";

        let hours = Math.floor(minutes / 60);
        let mins = minutes % 60;
        return hours + "h " + mins + "m";
    }

    Component.onCompleted: {
        if (hasBattery)
            console.log("[BatteryData] Found battery:", battery.nativePath);
        else
            console.log("[BatteryData] No battery found");
    }
}
