import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: wpManager

    property var availableWallpapers: []
    property var wallpapers: SettingsManager.wallpapers
    property string wallpapersPath: Quickshell.shellDir + SettingsManager.wallpapersPath
    property Process setWallpaperProcess
    property Process loadAvailableWallpaperProcess
    property Process setAllWallpapersProcess

    function loadAvailableWallpapers() {
        loadAvailableWallpaperProcess.running = true;
    }

    function setWallpaper(path, screenName) {
        setWallpaperProcess.screenName = screenName;
        setWallpaperProcess.wpPath = path;
        setWallpaperProcess.running = true;
    }

    function setAllWallpapers() {
        if (wallpapers.length === 0)
            return ;

        let commands = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            let wp = wallpapersPath + "/" + wallpapers[i % wallpapers.length];
            let screen = Quickshell.screens[i].name;
            commands.push(`swww img -o ${screen} "${wp}" --transition-type random`);
        }
        let fullCommand = commands.join(" && ");
        setAllWallpapersProcess.command = ["sh", "-c", fullCommand];
        setAllWallpapersProcess.running = true;
    }

    onWallpapersChanged: {
        setAllWallpapers();
    }
    onWallpapersPathChanged: {
        loadAvailableWallpapers();
        setAllWallpapers();
    }

    setAllWallpapersProcess: Process {
        running: false
        command: []
        onRunningChanged: {
            if (!running)
                console.log("[WallpaperManager] All wallpapers set");

        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.error("[WallpaperManager] Wallpaper set error:", text);

            }
        }

    }

    loadAvailableWallpaperProcess: Process {
        running: false
        command: ["ls", wpManager.wallpapersPath]

        stdout: StdioCollector {
            onStreamFinished: {
                let validExtensions = [".png", ".jpg", ".jpeg", ".webp", ".gif"];
                let wallpapers = text.trim().split("\n").filter((f) => {
                    if (!f || f.startsWith("."))
                        return false;

                    let lower = f.toLowerCase();
                    return validExtensions.some((ext) => {
                        return lower.endsWith(ext);
                    });
                });
                wpManager.availableWallpapers = wallpapers;
            }
        }

    }

}
