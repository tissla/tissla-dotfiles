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

    function generateThemeFiles(themeId, terminalOnly = false) {
        generateProcess.terminalOnly = terminalOnly;
        generateProcess.themeId = themeId;
        generateProcess.running = true;
    }

    // hyprland needs an explicit reload to pick up generated config, niri doesnt
    function reloadCompositor(terminalOnly = false) {
        if (Compositor.isHyprland) {
            hyprctlProcess.terminalOnly = terminalOnly;
            hyprctlProcess.running = true;
        }

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
        property bool terminalOnly: false

        running: false
        command: ["bash", Quickshell.shellDir + "/../build-theme.sh", themeId].concat(terminalOnly ? ["--terminal-only"] : [])
        onExited: (exitCode, exitStatus) => {
            if (terminalOnly) {
                SettingsManager.terminalSettingsError = exitCode === 0 && exitStatus === 0
                    ? "" : "Couldn't apply terminal settings";
                if (exitCode === 0 && exitStatus === 0)
                    themeManager.reloadCompositor(true);
            } else if (exitCode === 0 && exitStatus === 0) {
                themeManager.reloadCompositor();
            }
        }

        stdout: SplitParser {
            onRead: (data) => {
            }
        }

    }

    hyprctlProcess: Process {
        property bool terminalOnly: false
        running: false
        command: ["hyprctl", "reload"]
        onExited: (exitCode, exitStatus) => {
            if (terminalOnly && (exitCode !== 0 || exitStatus !== 0))
                SettingsManager.terminalSettingsError = "Couldn't reload Hyprland";
        }
    }

}
