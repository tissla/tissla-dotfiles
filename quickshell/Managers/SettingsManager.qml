pragma Singleton
import ".."
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: settings

    property bool barTransparentBackground: false
    property int barHeight: 40
    property string barPosition: "bottom"
    property string theme: "tissla"
    property real terminalOpacity: 0.85
    property bool terminalBlur: false
    property bool _rebuildTerminal: false
    property string terminalSettingsError: ""
    readonly property bool terminalSettingsBusy: settingsSaver.running || ThemeManager.generateProcess.running || ThemeManager.hyprctlProcess.running
    property bool border: true
    property var weatherCoords: []
    property string wallpapersPath: ""
    property var screenConfigs: ({})
    property string notificationPosition: ""
    property var settingsFile
    property Process settingsSaver
    // caches the concatenated module list per screen so getScreenModules()
    // returns the same array reference when left/center/right haven't
    // actually changed — otherwise every screenConfigs reassignment (e.g.
    // picking a wallpaper) would hand Repeater/Variants a brand-new array
    // and force a full teardown/rebuild of every module and widget.
    property var _moduleListCache: ({})

    function setTheme(themeId) {
        console.log("[SettingsManager] setTheme called:", themeId);
        settings.theme = themeId;
        saveSettings();
    }

    function setTerminalAppearance(opacity, blur) {
        if (terminalSettingsBusy || !Number.isFinite(opacity) || typeof blur !== "boolean")
            return;
        const value = Math.max(0, Math.min(1, Math.round(opacity * 100) / 100));
        terminalSettingsError = "";
        terminalOpacity = value;
        terminalBlur = blur;
        _rebuildTerminal = true;
        saveSettings();
    }

    function saveSettings() {
        console.log("[SettingsManager] saveSettings START");
        let json = {
            "bar": {
                "transparentBackground": barTransparentBackground,
                "height": barHeight,
                "position": barPosition,
                "border": border
            },
            "theme": theme,
            "terminal": {
                "opacity": terminalOpacity,
                "blur": terminalBlur
            },
            "wallpapersPath": wallpapersPath,
            "weatherCoords": weatherCoords,
            "screens": []
        };
        for (let screenName in screenConfigs) {
            json.screens.push({
                "name": screenName,
                "isPrimary": screenConfigs[screenName].isPrimary || false,
                "wallpaper": screenConfigs[screenName].wallpaper,
                "modules": {
                    "left": screenConfigs[screenName].left || [],
                    "center": screenConfigs[screenName].center || [],
                    "right": screenConfigs[screenName].right || []
                }
            });
        }

        settingsFile.setText(JSON.stringify(json, null, 2));
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

    function getPrimaryWallpaper() {
        for (let name in screenConfigs) {
            if (screenConfigs[name].isPrimary === true)
                return screenConfigs[name].wallpaper;
        }
        return "";
    }

    function getScreenModules(screenName) {
        const cfg = getScreenConfig(screenName);
        const left = cfg.left || [];
        const center = cfg.center || [];
        const right = cfg.right || [];
        const cached = _moduleListCache[screenName];
        if (cached && cached.left === left && cached.center === center && cached.right === right)
            return cached.result;

        const mods = left.concat(center, right);
        _moduleListCache[screenName] = {
            "left": left,
            "center": center,
            "right": right,
            "result": mods
        };
        return mods;
    }

    function isPrimary(screenName) {
        const cfg = screenConfigs[screenName];
        return cfg && cfg.isPrimary === true;
    }

    Component.onCompleted: {
        console.log("[SettingsManager] SettingsManager initialized");
    }

    settingsFile: FileView {
        path: Quickshell.shellDir + "/settings.json"
        watchChanges: true
        onFileChanged: this.reload()
        blockLoading: true

        onLoaded: {
            const json = JSON.parse(this.text());
            if (json.bar) {
                if (json.bar.transparentBackground !== undefined)
                    settings.barTransparentBackground = json.bar.transparentBackground;

                if (json.bar.height !== undefined)
                    settings.barHeight = json.bar.height;

                if (json.bar.position !== undefined)
                    settings.barPosition = json.bar.position;

                if (json.bar.border !== undefined)
                    settings.border = json.bar.border;
            }
            if (json.terminal) {
                if (typeof json.terminal.opacity === "number" && Number.isFinite(json.terminal.opacity))
                    settings.terminalOpacity = Math.max(0, Math.min(1, json.terminal.opacity));
                if (typeof json.terminal.blur === "boolean")
                    settings.terminalBlur = json.terminal.blur;
            }
            if (json.theme)
                settings.theme = json.theme;

            if (json.weatherCoords)
                settings.weatherCoords = json.weatherCoords;

            if (json.wallpapersPath)
                settings.wallpapersPath = json.wallpapersPath;

            if (json.screens && Array.isArray(json.screens)) {
                let configs = {};
                for (let i = 0; i < json.screens.length; i++) {
                    let screen = json.screens[i];
                    if (!screen.name || !screen.modules)
                        continue;

                    configs[screen.name] = {
                        "left": screen.modules.left || [],
                        "center": screen.modules.center || [],
                        "right": screen.modules.right || [],
                        "isPrimary": screen.isPrimary === true,
                        "wallpaper": screen.wallpaper || []
                    };
                }
                settings.screenConfigs = configs;
                console.log("[SettingsManager] Loaded", Object.keys(configs).length, "screen configs");
            }
        }

        onSaved: {
            if (!settings._rebuildTerminal)
                return;
            settings._rebuildTerminal = false;
            ThemeManager.generateThemeFiles(settings.theme, true);
        }
    }
}
