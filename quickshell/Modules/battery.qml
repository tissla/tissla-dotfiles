import ".."
import QtQuick

BaseModule {
    id: batteryModule

    visible: BatteryDataProvider.hasBattery
    widgetId: "battery"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    moduleIcon: {
        if (!BatteryDataProvider.hasBattery)
            return "";

        let level = BatteryDataProvider.batteryLevel;
        let charging = BatteryDataProvider.isCharging;
        // Charging icons
        if (charging) {
            if (level >= 90)
                return "󰂅";

            if (level >= 70)
                return "󰂋";

            if (level >= 50)
                return "󰂊";

            if (level >= 30)
                return "󰢞";

            if (level >= 10)
                return "󰢝";

            return "󰢜";
        }
        // Discharging icons
        if (level >= 90)
            return "󰁹";

        if (level >= 80)
            return "󰂂";

        if (level >= 70)
            return "󰂁";

        if (level >= 60)
            return "󰂀";

        if (level >= 50)
            return "󰁿";

        if (level >= 40)
            return "󰁾";

        if (level >= 30)
            return "󰁽";

        if (level >= 20)
            return "󰁼";

        if (level >= 10)
            return "󰁻";

        return "󰁺";
    }
    moduleText: BatteryDataProvider.hasBattery ? BatteryDataProvider.batteryLevel + "%" : ""
}
