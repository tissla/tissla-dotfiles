import ".."
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: themeManager

    // process
    property Process generateProcess
    property Process getAvailableThemesProcess
    property Process saveProcess
    property Process hyprctlProcess
    // path
    property string themesPath: Quickshell.shellDir + "/../themes/index.json"
    // theme params
    property var availableThemes: []
    property string activeTheme: SettingsManager.theme

    // set theme from themesData
    function setTheme(themeId) {
        activeTheme = themeId;
        if (themeId === "matugen") {
            MatugenService.generateTheme();
        } else {
            generateThemeFiles(themeId);
        }

        SettingsManager.setTheme(themeId);
    }

    function getAvailableThemes() {
        getAvailableThemesProcess.running = true;
    }

    function generateThemeFiles(themeId) {
        generateProcess.themeId = themeId;
        generateProcess.running = true;
    }

    // hyprland needs an explicit reload to pick up generated config, niri doesnt
    function reloadCompositor() {
        if (Compositor.isHyprland)
            hyprctlProcess.running = true;

    }

    Component.onCompleted: {
        getAvailableThemes();
    }

    getAvailableThemesProcess: Process {
        running: false
        command: ["cat", themeManager.themesPath]

        stdout: StdioCollector {
            onStreamFinished: {
                let data = JSON.parse(text);
                if (data.themes && Array.isArray(data.themes))
                    themeManager.availableThemes = ["matugen", ...data.themes];
                else
                    themeManager.availableThemes = ["matugen"];
                console.log("[ThemeManager] Available themes:", themeManager.availableThemes.join(", "));
            }
        }

    }

    // generates theme files for theme
    generateProcess: Process {
        property string themeId: ""

        running: false
        command: ["bash", "-c", Quickshell.shellDir + "/../build-theme.sh " + themeId + " >/dev/null 2>&1"]
        onRunningChanged: {
            if (!running && themeId !== "")
                themeManager.reloadCompositor();

        }

        stdout: SplitParser {
            onRead: (data) => {
            }
        }

    }

    hyprctlProcess: Process {
        running: false
        command: ["hyprctl", "reload"]
    }

}
