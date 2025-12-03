import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: settings

    property bool barTransparentBackground: false
    property int barHeight: 40
    property string barPosition: "bottom"
    // screen config map binding
    property var screenConfigs: ({
    })
    property bool autoReload: false
    property int reloadInterval: 5000
    property Timer reloadTimer
    property Process settingsLoader

    function loadSettings() {
        settingsLoader.running = true;
    }

    function getScreenConfig(screenName) {
        console.log("Getting config for screen:", screenName);
        if (screenConfigs && screenConfigs[screenName]) {
            console.log("Found config for:", screenName);
            return screenConfigs[screenName];
        } else {
            console.log("No config found for:", screenName, "- using default");
            return {
                "left": ["WorkspaceModule"],
                "center": [],
                "right": ["ClockModule"]
            };
        }
    }

    Component.onCompleted: {
        console.log("📝 SettingsManager initialized");
        loadSettings();
    }

    reloadTimer: Timer {
        interval: settings.reloadInterval
        running: settings.autoReload
        repeat: true
        onTriggered: {
            loadSettings();
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
                    if (json.general) {
                        if (json.general.clockFormat24hr !== undefined)
                            settings.clockFormat24hr = json.general.clockFormat24hr;

                        if (json.general.showSeconds !== undefined)
                            settings.showSeconds = json.general.showSeconds;

                    }
                    if (json.bar) {
                        if (json.bar.transparentBackground !== undefined)
                            settings.barTransparentBackground = json.bar.transparentBackground;

                        if (json.bar.height !== undefined)
                            settings.barHeight = json.bar.height;

                        if (json.bar.position !== undefined)
                            settings.barPosition = json.bar.position;

                    }
                    if (json.screens && Array.isArray(json.screens)) {
                        let configs = {
                        };
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
                        console.log("📝 Loaded", Object.keys(configs).length, "screen configs");
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
            onRead: (data) => {
                settingsLoader.buffer += data;
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.includes("No such file"))
                    console.log("⚠️ settings.json not found");

            }
        }

    }

}
