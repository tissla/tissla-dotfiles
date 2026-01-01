import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    // load themesData
    // generate theme files (using active on themes.json)

    id: themeManager

    // process
    property Process generateProcess
    property Process getAvailableThemesProcess
    property Process saveProcess
    // path
    property string themesPath: Quickshell.shellDir + "/../themes/themes.json"
    // theme params
    property var availableThemes: []
    property string activeTheme: SettingsManager.theme

    // set theme from themesData
    function setTheme(themeId) {
        activeTheme = themeId;
        generateThemeFiles(themeId);
        SettingsManager.setTheme(themeId);
    }

    function getAvailableThemes() {
        getAvailableThemesProcess.running = true;
    }

    function generateThemeFiles(themeId) {
        generateProcess.themeId = themeId;
        generateProcess.running = true;
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
                let themes = [];
                if (data.themes && Array.isArray(data.themes)) {
                    for (let i = 0; i < data.themes.length; i++) {
                        let theme = data.themes[i];
                        if (theme.id && themes.indexOf(theme.id) === -1)
                            themes.push(theme.id);

                    }
                }
                themeManager.availableThemes = themes;
                console.log("[ThemeManager] Available themes:", themes.join(", "));
            }
        }

    }

    // generates theme files for theme
    generateProcess: Process {
        property string themeId: ""

        running: false
        command: [Quickshell.shellDir + "/../build-theme.sh", themeId]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[ThemeManager] Generated theme files for theme:", themeId);
            }
        }

    }

}
