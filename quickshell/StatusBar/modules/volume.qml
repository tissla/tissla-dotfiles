import "../.."
import QtQuick

BaseModule {
    id: volumeModule

    widgetId: "volume"
    Component.onCompleted: {
        WidgetManager.registerModule(widgetId, this);
    }
    moduleIcon: {
        if (VolumeProvider.isMuted)
            return "󰝟";

        if (VolumeProvider.volume > 50)
            return "";

        if (VolumeProvider.volume > 0)
            return "";

        return "󰝟";
    }
    moduleText: VolumeProvider.volume + "%"
    textWidth: Theme.fontSizeBase * 2
}
