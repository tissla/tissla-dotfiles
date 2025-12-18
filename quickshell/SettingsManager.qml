pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: settings

    property bool barTransparentBackground: false
    property int barHeight: 40
    property string barPosition: "bottom"
    // screen config map binding
    property var screenConfigs: ({})
    property bool autoReload: false
    property int reloadInterval: 5000
    property Timer reloadTimer
    property Process settingsLoader

    function loadSettings() {
        settingsLoader.running = true;
    }

    function getScreenConfig(screenName) {
        console.log("[SettingsManager] Getting config for screen:", screenName);
        if (screenConfigs && screenConfigs[screenName]) {
            console.log("[SettingsManager] Found config for:", screenName);
            return screenConfigs[screenName];
        } else {
            console.log("[SettingsManager] No config found for:", screenName, "- using default");
            return {
                "left": ["workspaces"],
                "center": [],
                "right": [""]
            };
        }
    }

    Component.onCompleted: {
        console.log("[SettingsManager] SettingsManager initialized");
        loadSettings();
    }

    reloadTimer: Timer {
        interval: settings.reloadInterval
        running: settings.autoReload
        repeat: true
        onTriggered: {
            settings.loadSettings();
        }
    }

    settingsLoader: Process {
        property string buffer: ""

        running: false
        command: ["cat", Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        onRunningChanged: {
            if (!running && buffer !== "") {
                try {
                    const json = JSON.parse(buffer);
                    if (json.bar) {
                        if (json.bar.transparentBackground !== undefined)
                            settings.barTransparentBackground = json.bar.transparentBackground;

                        if (json.bar.height !== undefined)
                            settings.barHeight = json.bar.height;

                        if (json.bar.position !== undefined)
                            settings.barPosition = json.bar.position;
                    }
                    if (json.screens && Array.isArray(json.screens)) {
                        let configs = {};
                        for (let i = 0; i < json.screens.length; i++) {
                            let screen = json.screens[i];
                            if (!screen.name || !screen.modules)
                                continue;

                            configs[screen.name] = {
                                "left": screen.modules.left || [],
                                "center": screen.modules.center || [],
                                "right": screen.modules.right || []
                            };
                        }
                        settings.screenConfigs = configs;
                        console.log("[SettingsManager] Loaded", Object.keys(configs).length, "screen configs");
                    }
                } catch (e) {
                    console.log("❌ Error parsing settings.json:", e);
                }
                buffer = "";
            } else if (running) {
                buffer = "";
            }
        }

        stdout: SplitParser {
            onRead: data => {
                settingsLoader.buffer += data;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("No such file"))
                    console.log("[SettingsManager] settings.json not found");
            }
        }
    }
}
