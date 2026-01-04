import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: settings

    property bool barTransparentBackground: false
    property int barHeight: 40
    property string barPosition: "bottom"
    property string theme: "tissla"
    property var wallpapers: []
    property string wallpapersPath: ""
    property var screenConfigs: ({
    })
    property Process settingsLoader
    property Process settingsSaver

    function loadSettings() {
        settingsLoader.running = true;
    }

    function setTheme(themeId) {
        console.log("[SettingsManager] setTheme called:", themeId);
        settings.theme = themeId;
        saveSettings();
    }

    function saveSettings() {
        console.log("[SettingsManager] saveSettings START");
        let json = {
            "bar": {
                "transparentBackground": barTransparentBackground,
                "height": barHeight,
                "position": barPosition
            },
            "theme": theme,
            "wallpapers": wallpapers,
            "wallpapersPath": wallpapersPath,
            "screens": []
        };
        for (let screenName in screenConfigs) {
            json.screens.push({
                "name": screenName,
                "isPrimary": screenConfigs[screenName].isPrimary || false,
                "modules": {
                    "left": screenConfigs[screenName].left || [],
                    "center": screenConfigs[screenName].center || [],
                    "right": screenConfigs[screenName].right || []
                }
            });
        }
        let jsonString = JSON.stringify(json, null, 2);
        console.log("[SettingsManager] About to save JSON (first 100 chars):", jsonString.substring(0, 100));
        settingsSaver.jsonData = jsonString;
        settingsSaver.running = true;
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
                "right": []
            };
        }
    }

    function getScreenModules(screenName) {
        const cfg = getScreenConfig(screenName);
        const mods = (cfg.left || []).concat(cfg.center || [], cfg.right || []);
        return mods;
    }

    function isPrimary(screenName) {
        const cfg = screenConfigs[screenName];
        return cfg && cfg.isPrimary === true;
    }

    Component.onCompleted: {
        console.log("[SettingsManager] SettingsManager initialized");
        loadSettings();
    }

    settingsLoader: Process {
        property string buffer: ""

        running: false
        command: ["cat", Quickshell.shellDir + "/settings.json"]
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
                    if (json.wallpapers)
                        settings.wallpapers = json.wallpapers;

                    if (json.theme)
                        settings.theme = json.theme;

                    if (json.wallpapersPath)
                        settings.wallpapersPath = json.wallpapersPath;

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
                                "right": screen.modules.right || [],
                                "isPrimary": screen.isPrimary === true
                            };
                        }
                        settings.screenConfigs = configs;
                        console.log("[SettingsManager] Loaded", Object.keys(configs).length, "screen configs");
                    }
                } catch (e) {
                    console.log("Error parsing settings.json:", e);
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
                    console.log("[SettingsManager] settings.json not found");

            }
        }

    }

    settingsSaver: Process {
        property string jsonData: ""

        running: false
        command: ["sh", "-c", "echo '" + jsonData.replace(/'/g, "'\\''") + "' > " + Quickshell.env("HOME") + "/.config/quickshell/settings.json"]
        onRunningChanged: {
            console.log("[SettingsManager] Saver running:", running);
            if (!running)
                console.log("[SettingsManager] Saved settings.json");

        }

        stderr: StdioCollector {
            onStreamFinished: {
                if (text.length > 0)
                    console.error("[SettingsManager] Save ERROR:", text);

            }
        }

    }

}
