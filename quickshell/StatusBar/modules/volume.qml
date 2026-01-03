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
    onScrollCallback: (delta) => {
        if (delta > 0)
            VolumeProvider.setVolume(VolumeProvider.volume + 5);
        else
            VolumeProvider.setVolume(VolumeProvider.volume - 5);
    }
}
