import ".."
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: wpManager

    property var availableWallpapers: []
    property var wallpapers: {
        let result = ({
        });
        for (let name in SettingsManager.screenConfigs) {
            result[name] = SettingsManager.screenConfigs[name].wallpaper || "";
        }
        return result;
    }
    property string wallpapersPath: Quickshell.shellDir + SettingsManager.wallpapersPath
    property Process setWallpaperProcess
    property Process loadAvailableWallpaperProcess
    property Process setAllWallpapersProcess

    function loadAvailableWallpapers() {
        loadAvailableWallpaperProcess.running = true;
    }

    function setAllWallpapers() {
        if (Object.keys(wallpapers).length === 0)
            return ;

        let commands = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            let screen = Quickshell.screens[i].name;
            let wpFile = wallpapers[screen];
            if (!wpFile)
                continue;

            let wp = wallpapersPath + "/" + wpFile;
            if (wallpapersPath != Quickshell.shellDir)
                commands.push(`twp-cli set -output ${screen} -path "${wp}"`);

        }
        if (commands.length === 0)
            return ;

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
