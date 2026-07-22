import ".."
import QtQuick
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property Process createThemeProcess
    property string wpPath

    function generateTheme() {
        let wp = SettingsManager.getPrimaryWallpaper();
        if (!wp) {
            console.log("[MatugenService] No primary wallpaper set, skipping");
            return;
        }
        wpPath = WallpaperManager.wallpapersPath + "/" + wp;
        createThemeProcess.running = true;
    }

    createThemeProcess: Process {
        running: false
        command: ["matugen", "image", root.wpPath, "--prefer", "saturation"]
        onRunningChanged: {
            if (!running)
                ThemeManager.generateThemeFiles("matugen");

        }
    }

}
