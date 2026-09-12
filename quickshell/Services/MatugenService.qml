import ".."
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property Process createThemeProcess
    property string wpPath: ""
    readonly property string primaryWallpaper: SettingsManager.getPrimaryWallpaper()
    readonly property string requestedPath: primaryWallpaper ? WallpaperManager.wallpapersPath + "/" + primaryWallpaper : ""
    property Timer regenerateTimer: Timer {
        interval: 250
        onTriggered: root.generateTheme()
    }

    onRequestedPathChanged: {
        if (ThemeManager.activeTheme === "matugen")
            regenerateTimer.restart();
    }

    function generateTheme() {
        if (ThemeManager.activeTheme !== "matugen" || !requestedPath)
            return;
        // Keep the running process arguments stable. Its completion checks the
        // latest selection and starts another generation if necessary.
        if (createThemeProcess.running)
            return;
        regenerateTimer.stop();
        wpPath = requestedPath;
        createThemeProcess.running = true;
    }

    createThemeProcess: Process {
        running: false
        command: ["matugen", "image", root.wpPath,
            "--config", Quickshell.shellDir + "/../matugen/config.toml",
            "--type", "scheme-vibrant", "--mode", "dark", "--prefer", "saturation"]
        onExited: (exitCode, exitStatus) => {
            if (ThemeManager.activeTheme !== "matugen")
                return;
            if (root.wpPath !== root.requestedPath) {
                root.regenerateTimer.restart();
                return;
            }
            if (exitCode === 0 && exitStatus === 0)
                ThemeManager.generateThemeFiles("matugen");
            else
                console.warn("[MatugenService] Theme generation failed:", exitCode);
        }
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim())
                    console.warn("[MatugenService]", text.trim());
            }
        }
    }
}
