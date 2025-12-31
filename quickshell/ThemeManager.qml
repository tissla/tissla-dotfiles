import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: themeManager

    property Process generateProcess
    property string themesPath: Quickshell.shellDir + "/../themes/themes.json"

    function generateThemeFiles() {
        generateProcess.running = true;
    }

    generateProcess: Process {
        running: false
        command: [Quickshell.shellDir + "/../build-theme.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[ThemeManager] Generated theme files");
            }
        }

    }

}
